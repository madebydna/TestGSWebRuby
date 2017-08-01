class Cacher

  attr_accessor :school

  # Known data types:
  # :census
  # :test_scores
  # :ratings
  # :school_reviews
  # :school_media
  # :esp_response
  # :feed_test_scores
  # :gsdata
  # :directory_census

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
        performance:      PerformanceCaching::PerformanceCacher,
        characteristics:  CharacteristicsCaching::CharacteristicsCacher,
        esp_responses:    EspResponsesCaching::EspResponsesCacher,
        reviews_snapshot: ReviewsCaching::ReviewsSnapshotCacher,
        progress_bar:     ProgressBarCaching::ProgressBarCacher,
        feed_test_scores: FeedTestScoresCacher,
        gsdata:           GsdataCaching::GsdataCacher,
        ratings:          RatingsCaching::RatingsCacher,
        directory_census: DirectoryCensusCaching::DirectoryCensusCacher
    }[key.to_s.to_sym]
  end

  # Should return true if param is a data type cacher depends on. See top of class for known data type symbols
  def self.listens_to?(_)
    raise NotImplementedError
  end

  def self.active?
    true
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
      ProgressBarCaching::ProgressBarCacher,
      FeedTestScoresCacher,
      GsdataCaching::GsdataCacher,
      RatingsCaching::RatingsCacher,
      DirectoryCensusCaching::DirectoryCensusCacher
    ]
  end

  def self.create_caches_for_data_type(school, data_type)
    cachers_for_data_type(data_type).each do |cacher_class|
      begin
        cacher_class.new(school).cache if cacher_class.active?
      # rescue => error
      #   error_vars = { data_type: data_type, school_state: school.state, school_id: school.id }
      #   GSLogger.error(:school_cache, error, vars: error_vars, message: 'Failed to build school cache')
      end
    end
  end

  def self.create_cache(school, cache_key)
    begin
      cacher_class = cacher_for(cache_key)
      # require 'pry'; binding.pry
      # return unless cacher_class.active?
      cacher = cacher_class.new(school)
      cacher.cache
    # rescue => error
    #   error_vars = { cache_key: cache_key, school_state: school.state, school_id: school.id }
    #   GSLogger.error(:school_cache, error, vars: error_vars, message: 'Failed to build school cache')
    end
  end

### BEGIN RATINGS CACHE CODE
# TODO move this out to its own classes structure

  def self.data_descriptions
    @_data_descriptions ||= Hash[DataDescription.all.map { |dd| [dd.data_key+dd.state.to_s, dd] }]
  end

  def self.test_data_breakdowns
    @_test_data_breakdowns = Hash[TestDataBreakdown.all.map { |f| [f.id, f] }]
  end

  def self.test_description_for(data_type_id,state)
    @@test_descriptions["#{data_type_id}#{state}"]
  end

### END RATINGS CACHE CODE

end

