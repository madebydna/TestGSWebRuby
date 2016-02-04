class DistrictCacher

  attr_accessor :district

  # Known data types:
  # :feed_test_scores
  # :ratings

  def initialize(district)
    @district = district
  end

  def cache
    final_hash = build_hash_for_cache
    district_cache = DistrictCache.find_or_initialize_by(
        district_id: district.id,
        state: district.state,
        name:self.class::CACHE_KEY
    )
    if final_hash.present?
      district_cache.update_attributes!(
          value: final_hash.to_json,
          updated: Time.now
      )
    elsif district_cache && district_cache.id.present?
      DistrictCache.destroy(district_cache.id)
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
        feed_test_scores:      TestScoresCaching::DistrictTestScoresCacher

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
        TestScoresCaching::DistrictTestScoresCacher
    ]
  end

  def self.create_cache(district, cache_key)


    begin
      if cache_key != 'ratings'
        cacher_class = cacher_for(cache_key)
        cacher = cacher_class.new(district)
        cacher.cache
      else
        ratings_cache_for_district(district)
      end
    rescue => error
      error_vars = { cache_key: cache_key, district_state: district.state, district_id: district.id }
      GSLogger.error(:district_cache, error, vars: error_vars, message: 'Failed to build district cache')
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


  def self.ratings_cache_for_district(district)
    # To do  change it  to get data for District Rating
    results_obj_array = TestDataSet.ratings_for_school(district)
    district_cache = DistrictCache.find_or_initialize_by(district_id: district.id,state: district.state,name: 'ratings')

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
      district_cache.update_attributes!(:value => results_hash_array.to_json, :updated => Time.now)
    elsif district_cache && district_cache.id.present?
      DistrictCache.destroy(district_cache.id)
    end
  end

### END RATINGS CACHE CODE

end
