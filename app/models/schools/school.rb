class School < ActiveRecord::Base
  include SchoolReviewConcerns
  include SchoolRouteConcerns

  LEVEL_CODES = {
    primary: 'p',
    preschool: 'p',
    elementary: 'e',
    middle: 'm',
    high: 'h',
    public: 'public OR charter',
    private: 'private',
    charter: 'charter'
  }

  METADATA_COLLECTION_ID_KEY = "collection_id"
  include ActionView::Helpers
  self.table_name='school'
  include StateSharding

  attr_accessible :name, :state, :school_collections, :district_id, :city, :street, :fax, :home_page_url, :phone,:modified, :modifiedBy, :level, :type, :active, :new_profile_school
  attr_writer :collections
  has_many :school_metadatas
  belongs_to :district

  scope :held, -> { joins("INNER JOIN gs_schooldb.held_school ON held_school.school_id = school.id and held_school.state = school.state") }

  scope :active, -> { where(active: true) }

  self.inheritance_column = nil

  def self.find_by_state_and_id(state, id)
    School.on_db(state.downcase.to_sym).find id rescue nil
  end

  def self.within_district(district)
    on_db(district.shard).active.where(district_id: district.id)
  end

  def self.within_city(state_abbreviation, city_name)
    on_db(state_abbreviation.downcase.to_sym).active.where(city: city_name).order(:name)
  end

  def census_data_for_data_types(data_types = [])
    CensusDataSet.on_db(state.downcase.to_sym).by_data_types(state, data_types)
  end

  def census_data_school_values
    CensusDataSchoolValue.on_db(state.downcase.to_sym).where(school_id: id)
  end

  def collections
    @collections ||= (
      Collection.for_school(state, id)
    )
  end

  def collection_ids
    @_collection_ids ||= (
      collections.map(&:id)
    )
  end

  # Returns first collection or nil if none
  def collection
    collections.first
  end

  def hub_city
    if collection
      hub = HubCityMapping.find_by(collection_id: collection.id)
      hub.city
    else
      city
    end
  end

  def self.preload_school_metadata!(schools)
    return unless schools.present?

    if schools.map(&:state).uniq.size > 1
      raise ArgumentError('Does not yet support multiple states')
    end

    school_to_id_map = schools.each_with_object({}) do |school, hash|
      school.instance_variable_set(:@school_metadata, Hashie::Mash.new)
      hash[school.id] = school
    end

    school_metadatas = SchoolMetadata.on_db(schools.first.shard).where(school_id: schools.map(&:id))
    school_metadatas.each do |metadata|
      school = school_to_id_map[metadata.school_id]
      metadata_hash = school.instance_variable_get(:@school_metadata)
      metadata_hash[metadata.meta_key] = metadata.meta_value
      school.instance_variable_set(:@school_metadata, metadata_hash)
    end
  end

  # get the schools metadata
  def school_metadata
    @school_metadata ||= (
      metadata_hash = Hashie::Mash.new()
      school_metadatas = SchoolMetadata.by_school_id(shard,id)
      school_metadatas.each do |metadata|
        metadata_hash[metadata.meta_key] = metadata.meta_value
      end
      metadata_hash
    )
  end
  alias_method :metadata, :school_metadata

  def school_media_first_hash
    @school_media_first_hash ||= (
      result = SchoolMedia.fetch_school_media self, 1
      result.first['hash']  unless result.nil? || result.empty?
    )
  end

  def school_media
    SchoolMedia.fetch_school_media self, ''
  end

# returns true or false - takes p,e,m,h as an array
  def includes_level_code? (arr_levels)
    (level_code_array & (Array(arr_levels))).any?
  end

  def private_school?
    type == 'private'
  end

  def public_or_charter?
    ['public', 'charter'].include?(type)
  end

  def preschool?
    level_code == 'p'
  end

  def includes_preschool?
    includes_level_code? 'p'
  end

  def includes_highschool?
    includes_level_code? 'h'
  end

  def level_code_array
    level_code.split ','
  end

  def great_schools_rating
    school_metadata[:overallRating].presence
  end

  def school_ratings
    SchoolRating.where(state: state, school_id: id)
  end

  def state_name
    States.state_name(state)
  end

  def level_codes
    level_code.split(',') if level_code.present?
  end

  #Temporary work around, since with db charmer we cannot directly say school.district.name.
  #It looks at the wrong database in that case.
  def district
    return @district if defined?(@district)
    @district = District.on_db(self.shard).where(id: self.district_id).first
  end

  # returns true if school is on held school list (associated with school reviews)
  def held?
    if !defined?(@held)
      @held = HeldSchool.has_school?(self)
    end
    @held
  end

  def all_census_data
    @all_census_data ||= nil
    return @all_census_data if @all_census_data

    all_configured_data_types = page.all_configured_keys 'census_data'

    # Get data for all data types
    @all_census_data = CensusDataForSchoolQuery.new(self).latest_data_for_school all_configured_data_types
  end

  def held_school
    HeldSchool.where(state: state, school_id: id).first
  end

  def held_school?
    HeldSchool.exists?(state: state, school_id: id)
  end

  def show_ads
    if collection.present?
      return collection.show_ads
    end
    return true
  end

  def neighbors
    prefix = "_#{shard}"
    prefix << '_test' if Rails.env.test?
    School.on_db(shard).joins("inner join #{prefix}.nearby on school.id = nearby.neighbor and nearby.school = #{id}")
  end

  def self.for_collection(collection_id)
    gs_schooldb = 'gs_schooldb'
    gs_schooldb << '_test' if Rails.env.test?
    joins("INNER JOIN #{gs_schooldb}.school_collections sc ON school_id = school.id
           and sc.state = school.state")
      .where('collection_id = ?', collection_id)
  end

  def self.for_states_and_ids(states, ids)
    raise ArgumentError, 'States and school IDs provided must be provided' unless states.present? && ids.present?
    raise ArgumentError, 'Number of states and school IDs provided must be equal' unless states.size == ids.size

    schools = []

    state_to_id_hashes = []
    states.each_with_index do |state, index|
      state_to_id_hashes <<
        {
          state: state,
          id: ids[index]
        }
    end
    states_to_ids = state_to_id_hashes.group_by { |pair| pair[:state] }
    states_to_ids.each do |state, values|
      values.map! { |pair| pair[:id] }
    end

    states_to_ids.each do |state, ids|
      schools += self.on_db(state.downcase.to_sym).where(id: ids, active: true).to_a
    end

    # Sort schools the way they were passed in
    schools = schools.sort_by do |school|
      state_to_id_hashes.index(
        {
          state: school.state.downcase,
          id: school.id
        }
      )
    end
  end

  def pk8?
    includes_level_code?(%w[p e m])
  end

  def k8?
    includes_level_code?(%w[e m])  &&  !preschool?
  end

  SCHOOL_CACHE_KEYS = %w(characteristics esp_responses progress_bar test_scores nearby_schools)

  def cache_results

    @school_cache_results ||= (query_results = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS).include_schools(state, id).query

    school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)

    school_cache_results.decorate_schools(Array(self)).first
    )
  end

  def nearby_schools_for_list(list_name)
    if cache_results.present? && cache_results.nearby_schools.is_a?(Hash)
      cache_results.nearby_schools[list_name] || []
    else
      []
    end
  end

  def self.for_collection_ordered_by_name(state,collection_id)
    raise ArgumentError, 'state and collection_id provided must be provided' unless state.present? && collection_id.present?
    collection = Collection.find(collection_id)
    collection.schools
  end

  def demo_school?
    notes.present? && notes.match("GREATSCHOOLS_DEMO_SCHOOL_PROFILE")
  end

  # def notes
  #   @notes ||= SchoolNote.find_by_school(self)
  # end
end
