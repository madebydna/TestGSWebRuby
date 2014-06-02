class School < ActiveRecord::Base
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

  attr_accessible :name, :state, :school_collections, :district_id, :city
  attr_writer :collections
  has_many :school_metadatas
  belongs_to :district

  scope :held, -> { joins("INNER JOIN gs_schooldb.held_school ON held_school.school_id = school.id and held_school.state = school.state") }

  self.inheritance_column = nil

  def self.find_by_state_and_id(state, id)
    School.on_db(state.downcase.to_sym).find id rescue nil
  end

  def census_data_for_data_types(data_types = [])
    CensusDataSet.on_db(state.downcase.to_sym).by_data_types(state, data_types)
  end

  def census_data_school_values
    CensusDataSchoolValue.on_db(state.downcase.to_sym).where(school_id: id)
  end

  def collections
    @collections ||= SchoolCollection.for_school(self)
  end

  # Returns first collection or nil if none
  def collection
    collections.first
  end

  # Returns first collection name if school belongs to one, otherwise nil
  def collection_name
    collection = self.collection
    if collection
      collection.name
    end
  end

  def hub_city
    collection = self.collection
    if collection
      collection.nickname
    else
      city
    end
  end

  # get the schools metadata
  def school_metadata
    metadata_hash = Hashie::Mash.new()
    school_metadatas = SchoolMetadata.on_db(shard).where(school_id: id)
    school_metadatas.each do |metadata|
      metadata_hash[metadata.meta_key] = metadata.meta_value
    end
    return metadata_hash
  end

  def school_media_first_hash
    result = SchoolMedia.fetch_school_media self, 1
    result.first['hash']  unless result.nil? || result.empty?
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

# need to find contiguous grade levels and insert a dash "-" between first and last
# pre K or PK is smallest
# KG or K is second smallest - convert KG to K
# Breaks in grade sequence is separated by a comma
# UG if alone will be written as Ungraded if at the end of a series append as "& Ungraded"
  def process_level
    level_array = level.split ','
    if level_array.blank?
      return nil
    end

    if level_array.length == 1
      if level_array[0] == 'KG'
        return 'K'
      elsif level_array[0] == 'UG'
        return 'Ungraded'
      end
      return level_array[0]
    end

    # some prep of array and detect ungraded
    ungraded = false
    level_array.each_with_index do | value, index |
      if (value == 'KG')
        level_array[index] = 'K'
      elsif (value == 'UG' )
        ungraded = true
      end
    end

    return_str = ''

    temp_array = ['PK','K','1','2','3','4','5','6','7','8','9','10','11','12']
      .map { |i| (level_array.include? i.to_s) ? i : '|' }
      .join(' ')
      .split('|')
      .each{|obj| obj.strip!}
      .reject(&:empty?)

    temp_array.each_with_index do |value, index|
      if index != 0
        return_str += ', '
      end
      inner_array = value.split(' ')
      return_str += inner_array.first
      if inner_array.length > 1
        # use first and last with dash
        return_str += '-' + inner_array.last
      end
    end

    if ungraded == true
      return_str += " & Ungraded"
    end
    return_str
  end

  def description
    snippet ||= %Q{#{name} is a #{type} school} unless name.empty? || type.empty?
    if snippet
      snippet << %Q{ that serves #{levels_description}} unless levels_description.nil?
      snippet << %Q{. It has received a GreatSchools rating of #{great_schools_rating} out of 10 based on academic quality.} unless great_schools_rating.nil?
    end
    snippet.presence
  end

  def great_schools_rating
    school_metadata[:overallRating].presence
  end

  def levels_description
    levels = process_level
    if levels.nil? || levels.include?('Ungraded')
      nil
    else
      levels.length > 2 ? "grades #{levels}" :  "grade #{levels}"
    end
  end

  # Return all reviews for this school
  def school_ratings
    SchoolRating.where(state: state, school_id: id)
  end

  # returns all reviews for
  def reviews
    SchoolRating.fetch_reviews self
  end

  # group_to_fetch, order_results_by, offset_start, quantity_to_return
  def reviews_filter( options ={} )
    #second parameter is group to filter by leave it as empty string '' for all
    #third parameter is order by - options are
    #   '' empty string is most recent first
    #   'oldest' is oldest first
    #   'rating_top' is by highest rating
    #   'rating_bottom' is by lowest rating
    SchoolRating.fetch_reviews self, group_to_fetch: options[:group_type], order_results_by: options[:order_results_by], offset_start: options[:offset_start], quantity_to_return: options[:quantity_to_return]
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
    @district ||= District.on_db(self.shard).where(id: self.district_id).first
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

end
