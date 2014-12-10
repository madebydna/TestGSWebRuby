class Cacher

  attr_accessor :school

  # Known data types:
  # :census
  # :test_scores
  # :ratings
  # :school_reviews
  # :school_media
  # :esp_response

  def initialize(school)
    @school = school
  end

  def cache
    final_hash = build_hash_for_cache

    school_cache = SchoolCache.find_or_initialize_by(
        school_id: school.id,
        state: school.state,
        name:self.class::CACHE_KEY
    )

    if final_hash.present?
      school_cache.update_attributes!(
          value: final_hash.to_json,
          updated: Time.now
      )
    elsif school_cache && school_cache.id.present?
      SchoolCache.destroy(school_cache.id)
    end
  end

  def active_record_to_hash(configuration_map, obj)
    rval_map = {}
    configuration_map.each do |key, val|
      if obj.attributes.include?(key.to_s)
        rval_map[val] = obj[key]
      elsif obj.respond_to?(key)
        rval_map[val] = obj.send(key)
      else
        Rails.logger.error "ERROR: Can't find attribute or method named #{key} in #{obj}"
      end
    end
    rval_map
  end

  def build_hash_for_cache
    raise NotImplementedError
  end

  def self.cacher_for(key)
    {

        test_scores:      TestScoresCaching::BreakdownsCacher,
        characteristics:  CharacteristicsCaching::CharacteristicsCacher,
        esp_responses:    EspResponsesCaching::EspResponsesCacher,
        reviews_snapshot: ReviewsCaching::ReviewsSnapshotCacher,
        progress_bar:     ProgressBarCaching::ProgressBarCacher

    }[key.to_s.to_sym]
  end

  # Should return true if param is a data type cacher depends on. See top of class for known data type symbols
  def self.listens_to?(_)
    raise NotImplementedError
  end

  def self.cachers_for_data_type(data_type)
    data_type_sym = data_type.to_s.to_sym
    registered_cachers.select {|cacher| cacher.listens_to? data_type_sym }
  end

  def self.registered_cachers
    @registered_cachers ||= [
      TestScoresCaching::BreakdownsCacher,
      CharacteristicsCaching::CharacteristicsCacher,
      EspResponsesCaching::EspResponsesCacher,
      ReviewsCaching::ReviewsSnapshotCacher,
      ProgressBarCaching::ProgressBarCacher
    ]
  end

  def self.create_caches_for_data_type(school, data_type)
    if data_type != :ratings
      cachers_for_data_type(data_type).each do |cacher_class|
        begin
          cacher_class.new(school).cache
        rescue => error
          Rails.logger.error "ERROR: populating school cache #{cacher_class} for school id: #{school.id} in state: #{school.state}." +
                                 "\nException : #{error.message}."
        end
      end
    else
      begin
        ratings_cache_for_school(school)
      rescue => error
        Rails.logger.error "ERROR: populating school cache ratings for school id: #{school.id} in state: #{school.state}." +
                               "\nException : #{error.message}."
      end
    end
  end

  def self.create_cache(school, cache_key)
    begin
      if cache_key != 'ratings'
        cacher_class = cacher_for(cache_key)
        cacher = cacher_class.new(school)
        cacher.cache
      else
        ratings_cache_for_school(school)
      end
    rescue => error
      Rails.logger.error "ERROR: populating school cache for school id: #{school.id} in state: #{school.state}." +
                             "\nException : #{error.message}."
    end
  end

### BEGIN RATINGS CACHE CODE
# TODO move this out to its own classes structure

  # Uses configuration_map to map attributes/methods in obj_array to keys in a hash
  def self.map_object_array_to_hash_array(configuration_map, obj_array)
    rval = []
    obj_array.each do |obj|
      rval << active_record_to_hash(configuration_map, obj)
    end
    rval
  end

  def self.active_record_to_hash(configuration_map, obj)
    rval_map = {}
    configuration_map.each do |key, val|
      if obj.attributes.include?(key.to_s)
        rval_map[val] = obj[key]
      elsif obj.respond_to?(key)
        rval_map[val] = obj.send(key)
      elsif key == :test_data_type_display_name
        # Hack until we get ratings into its own tiered class structure
        if obj.test_data_type
          rval_map[val] = obj.test_data_type.display_name
        end
      else
        Rails.logger.error "ERROR: Can't find attribute or method named #{key} in #{obj}"
      end
    end
    rval_map
  end

  def self.test_description_for(data_type_id,state)
    @@test_descriptions["#{data_type_id}#{state}"]
  end


  def self.ratings_cache_for_school(school)
    results_obj_array = TestDataSet.ratings_for_school(school)
    school_cache = SchoolCache.find_or_initialize_by(school_id: school.id,state: school.state,name: 'ratings')

    if results_obj_array.present?
      config_map = {
          data_type_id: 'data_type_id',
          year: 'year',
          school_value_text: 'school_value_text',
          school_value_float: 'school_value_float',
          test_data_type_display_name: 'name'
      }
      results_hash_array = map_object_array_to_hash_array(config_map, results_obj_array)
      # Prune out empty data sets
      results_hash_array.delete_if {|hash| hash['school_value_text'].nil? && hash['school_value_float'].nil?}
      school_cache.update_attributes!(:value => results_hash_array.to_json, :updated => Time.now)
    elsif school_cache && school_cache.id.present?
      SchoolCache.destroy(school_cache.id)
    end
  end

### END RATINGS CACHE CODE

end
