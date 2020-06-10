class SchoolRecord < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name= 'school_records'
  # need to review these modules
  # this module looks okay as it allows school to know reviews of themselves
  include SchoolReviewConcerns
  include SchoolRouteConcerns
  include GradeLevelConcerns

  attr_accessor :assigned
  # ! TODO: only java routing uses this column. Can remove eventually from school_record
  #:new_profile_school
  # attr_writer :collections
  # has_many :school_metadatas

 # invokes the unique_id getter
  before_validation :unique_id, on: :create

  LEVEL_CODES = {
    primary: 'p',
    preschool: 'p',
    elementary: 'e',
    middle: 'm',
    high: 'h',
    public: 'public',
    public_or_charter: 'public OR charter',
    private: 'private',
    charter: 'charter'
  }

  scope :held, -> { joins("INNER JOIN #{SchoolRecord.gs_schooldb_name}.held_school ON held_school.school_id = school_records.school_id and held_school.state = school_records.state") }

  scope :not_preschool_only, -> { where.not(level_code: 'p') }

  scope :include_district_name, lambda {
    select("school_records.*, dr.name as district_name")
      .joins("LEFT JOIN #{School.gs_schooldb_name}.district_records as dr on school_records.district_id = dr.district_id and dr.state = school_records.state")
  }

  def self.gs_schooldb_name
    Rails.env.test? ? "gs_schooldb_test" : "gs_schooldb"
  end

  scope :by_state, ->(state) { where(state: state) }
  scope :preschool_schools, -> { where('level_code like ?', "%#{LEVEL_CODES[:preschool]}%") }
  scope :elementary_schools, -> { where('level_code like ?', "%#{LEVEL_CODES[:elementary]}%") }
  scope :middle_schools, -> { where('level_code like ?', "%#{LEVEL_CODES[:middle]}%") }
  scope :high_schools, -> { where('level_code like ?', "%#{LEVEL_CODES[:high]}%") }
  scope :public_schools, -> { where('type = ?', LEVEL_CODES[:public]) }
  scope :charter_schools, -> { where('type = ?', LEVEL_CODES[:charter]) }
  scope :private_schools, -> { where('type = ?', LEVEL_CODES[:private]) }

  # This is because we use type (which is usually a reserved keyword) for if a school is public, private, or charter
  # this allows us to use it without ActiveRecord getting angry at us
  self.inheritance_column = nil

  # ! TODO: rewrite this
  # scope :find_by_state_and_id, lambda do |state, id|
  #   find_by(school_id: id, state: state)
  # end
  scope :find_by_state_and_id, ->(state, id) { find_by(school_id: id, state: state) }

  scope :find_by_state_and_ids, ->(state, ids) { where(school_id: ids, state: state) }

  # ! TODO: rewrite this
  # scope :ids_by_state, lambda do |state|
  #   where(state: state).active
  #                      .not_preschool_only
  #                      .order(:school_id)
  #                      .pluck(:school_id)
  # end

  scope :within_city, ->(state, city) { where(city: city, state: state.downcase).active.order(:name) }

  scope :within_state, ->(state) { where(state: state.downcase).active.order(:name) }

  # def self.find_by_state_and_id(state, id)
  #   find_by(school_id: id, state: state)
  # end

  # def self.find_by_state_and_ids(state, ids)
  #   where(school_id: ids, state: state)
  # end

  # def self.ids_by_state(state)
  #   where(state: state).active.not_preschool_only.order(:school_id).pluck(:school_id)
  # end

  def unique_id
    self[:unique_id] ||= "#{self.state}-#{self.school_id}"
  end

  # Given objects that have state and id, load school for each one
  # Used for Solr School Documents which doesn't have school_id
  def self.load_all_from_associates(associates)
    associates = associates.select { |o| o.state.present? && o.id.present? }

    # need a map so we can effeciently maintain order
    associate_state_school_ids_hash =
      associates.each_with_object({}) do |obj, hash|
        hash[[obj.state.downcase, obj.school_id.to_i]] = nil
      end

    state_to_id_map =
      associates
        .each_with_object({}) do |obj, hash|
          hash[obj.state] ||= []
          hash[obj.state] << obj.school_id
      end
    schools =
      state_to_id_map.flat_map do |(state, ids)|
        if block_given?
          yield(find_by_state_and_ids(state, ids)).to_a
        else
          find_by_state_and_ids(state, ids).to_a
        end
      end

    schools.each do |school|
      associate_state_school_ids_hash[[school.state.downcase, school.id.to_i]] = school
    end

    associate_state_school_ids_hash.values.compact
  end

  # def self.within_city(state_abbreviation, city_name)
  #   SchoolRecord.active.where(city: city_name, state: state_abbreviation.downcase).order(:name)
  # end

  # def self.within_state(state_abbreviation)
  #   SchoolRecord.active.where(state: state_abbreviation.downcase).order(:name)
  # end


  # TODO Do we need these collections methods?
  # !-----------------------------------
  # def collections
  #   @collections ||= (
  #     Collection.for_school(state, id)
  #   )
  # end

  # def collection_ids
  #   @_collection_ids ||= (
  #     collections.map(&:id)
  #   )
  # end

  # # Returns first collection or nil if none
  # def collection
  #   collections.first
  # end
  # !-----------------------------------

  # TODO are we still using HubCityMapping
  # def hub_city
  #   if collection
  #     hub = HubCityMapping.find_by(collection_id: collection.id)
  #     hub.city
  #   else
  #     city
  #   end
  # end

  # TODO need to verify
  # def self.preload_school_metadata!(schools)
  #   return unless schools.present?

  #   if schools.map(&:state).uniq.size > 1
  #     raise ArgumentError('Does not yet support multiple states')
  #   end

  #   school_to_id_map = schools.each_with_object({}) do |school, hash|
  #     school.instance_variable_set(:@school_metadata, Hashie::Mash.new)
  #     hash[school.id] = school
  #   end

  #   # school_metadatas = SchoolMetadata.on_db(schools.first.shard).where(school_id: schools.map(&:id))
  #   school_metadatas = SchoolMetadata.on_db("_#{schools.first.state.downcase}").where(school_id: schools.map(&:id))
  #   school_metadatas.each do |metadata|
  #     school = school_to_id_map[metadata.school_id]
  #     metadata_hash = school.instance_variable_get(:@school_metadata)
  #     metadata_hash[metadata.meta_key] = metadata.meta_value
  #     school.instance_variable_set(:@school_metadata, metadata_hash)
  #   end
  # end

  # TODO - Verify we still use
  # get the schools metadata
  # def school_metadata
  #   @school_metadata ||= (
  #     metadata_hash = Hashie::Mash.new
  #     school_metadatas = SchoolMetadata.by_school_id(shard,id)
  #     school_metadatas.each do |metadata|
  #       metadata_hash[metadata.meta_key] = metadata.meta_value
  #     end
  #     metadata_hash
  #   )
  # end
  # alias_method :metadata, :school_metadata

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
  def includes_level_code?(arr_levels)
    (level_code_array & (Array(arr_levels))).any?
  end

  def includes_type?(types)
    (type.downcase.split(',') & (Array(types))).any?
  end

  def private_school?
    type.downcase == 'private'
  end

  def public_or_charter?
    charter? || public?
  end

  def includes_charter?
    ['charter'].include?(type.downcase)
  end

  def includes_public?
    ['public'].include?(type.downcase)
  end

  def preschool?
    level_code == 'p'
  end

  def includes_preschool?
    includes_level_code? 'p'
  end

  def includes_elementaryschool?
    includes_level_code? 'e'
  end

  def includes_middleschool?
    includes_level_code? 'm'
  end

  def includes_highschool?
    includes_level_code? 'h'
  end

  def level_code_array
    level_code.split ','
  end

  # TODO: Are we still using school_metadata
  # def great_schools_rating
  #   school_metadata[:overallRating].presence
  # end

  def state_name
    States.state_name(state)
  end

  def level_codes
    level_code.split(',') if level_code.present?
  end

  def district
    # @district ||= DistrictRecord.by_state(state.downcase).where(district_id: self.district_id).first
    @district ||= DistrictRecord.by_state(state.downcase).find_by_district_id(district_id)
  end

  # returns true if school is on held school list (associated with school reviews)
  def held?
    unless defined?(@held)
      @held = HeldSchool.active_hold?(self)
    end
    @held
  end

  def held_school
    HeldSchool.where(state: state, school_id: school_id).first
  end

  def held_school?
    HeldSchool.exists?(state: state, school_id: school_id)
  end

  # state the directory is from
  def directory_state
    unique_id.split("-").first
  end

  # TODO: Do we migrate over `nearby`
  def neighbors
    prefix = "_#{directory_state}"
    prefix << '_test' if Rails.env.test?
    joins("inner join #{prefix}.nearby on school_records.school_id = nearby.neighbor and nearby.school = #{school_id}")
  end

  # TODO: Verify the query
  def self.for_collection(collection_id)
    gs_schooldb = 'gs_schooldb'
    gs_schooldb << '_test' if Rails.env.test?
    joins("INNER JOIN #{gs_schooldb}.school_collections sc ON school_id = school_records.school_id
           and sc.state = school_records.state")
      .where('collection_id = ?', collection_id)
  end

  # TODO: verify we still use
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

    # TODO: Change to reduce/inject method
    states_to_ids.each do |state, school_ids|
      # schools += self.on_db(state.downcase.to_sym).where(id: ids, active: true).to_a
      schools += where(school_id: school_ids, active: true, state: state).to_a
    end

    # Sort schools the way they were passed in
    schools = schools.sort_by do |school|
      state_to_id_hashes.index(
        {
          state: school.state.downcase,
          id: school.school_id
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

  def middle_school?
    level_code == 'm'
  end

  def high_school?
    level_code == 'h'
  end

  SCHOOL_CACHE_KEYS = %w(metrics esp_responses test_scores nearby_schools ratings)

  # TODO: Check if these are still used. Cache access should be sent to the data readers service objects
  def cache_results

    @school_cache_results ||= (query_results = SchoolCacheQuery.new.include_cache_keys(SCHOOL_CACHE_KEYS).include_schools(state, school_id).query

    school_cache_results = SchoolCacheResults.new(SCHOOL_CACHE_KEYS, query_results)

    school_cache_results.decorate_schools(Array(self)).first
    )
  end

  # TODO: same as above. Cache stuff should be used by data reader
  def nearby_schools_for_list(list_name)
    if cache_results.present? && cache_results.nearby_schools.is_a?(Hash)
      cache_results.nearby_schools[list_name] || []
    else
      []
    end
  end

  # TODO: appears unused
  def self.for_collection_ordered_by_name(state,collection_id)
    raise ArgumentError, 'state and collection_id provided must be provided' unless state.present? && collection_id.present?
    collection = Collection.find(collection_id)
    collection.schools
  end

  # TODO: uses caches too. See why though
  # TODO: What is ESP keys?
  def facebook_url
    cache_results.values_for(EspKeys::FACEBOOK_URL).first || metadata.facebook_url
  end

  def demo_school?
    notes.present? && notes.match("GREATSCHOOLS_DEMO_SCHOOL_PROFILE")
  end

  # todo: do we still use?
  def self.query_distance_function(lat, lon)
    miles_center_of_earth = 3959
    "(
    #{miles_center_of_earth} *
     acos(
       cos(radians(#{lat})) *
       cos( radians(school.lat) ) *
       cos(radians(school.lon) - radians(#{lon})) +
       sin(radians(#{lat})) *
       sin( radians(school.lat) )
     )
   )".squish
  end

  def claimed?
    @_claimed ||=
      EspMembership.where(
          active: 1,
          state: state,
          school_id: school_id
      ).present?
  end

  def mss_subscribers
    Subscription.mss_subscribers_for_school(self)
  end

  # TODO: see what this does. Do we need it?
  def self.preload_schools_onto_associates(associates)
    schools = School.load_all_from_associates(associates).map { |s| [[s.state, s.id], s] }.to_h
    associates.each do |associate|
      associate.school = schools[[associate.state, associate.school_id]]
    end
  end

  def self.update_from_school(school, state, log: false)
    school_record = find_by(unique_id: "#{state}-#{school.id}")
    school_record ||= new(unique_id: "#{state}-#{school.id}", state: state.to_s, school_id: school.id, geo_state: school.state)
    school_record.assign_attributes(
      school.attributes.symbolize_keys.except(
        :id, #id is set as school_id
        :modifiedBy, # updated in school_record as modified_by
        :active
      ).merge({
        modified_by: school.modifiedBy #updates modified_by
      })
    )

    # Note: this is required to see the actual attributes that failed validation because we
    # overwrite Rails's default error message
    begin
      if log && school_record.changed?
        puts "SchoolRecord #{school_record.unique_id} has changed"
        p school_record.changes
      end
      school_record.save!
    rescue ActiveRecord::RecordInvalid => error
      message = school_record.errors.messages.sort_by {|attr,msg| attr.to_s }.map do |attr, msg|
        "#{attr.capitalize} #{msg.first}"
      end.join("; ")
      raise "Validation failed: #{message}"
    end
  end

end