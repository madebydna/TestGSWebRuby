class SchoolCacheResults

  def initialize(cache_keys, query_results)
    @cache_keys = Array.wrap(cache_keys)
    @query_results = query_results
    @school_data = {}
    build_school_data_hash
  end

  def school_data_hash
    @school_data
  end

  def data_hash
    @school_data
  end

  def decorate_schools(schools)
    [*schools].map do |school|
      decorated = SchoolCacheDecorator.new(school, @school_data[[school.state.upcase, school.id]] || {})
      @cache_keys.each do |key|
        if module_for_key(key)
          decorated.send(:extend, (module_for_key(key)))
        end
      end
      decorated
    end
  end

  module HashWithSchoolCacheData
    def cache_data
      self
    end
  end

  def get_cache_object_for_school(state, school_id)
    hash = school_data_hash[[state.upcase, school_id]]
    if hash
      hash.send(:extend, HashWithSchoolCacheData)
      hash.keys.each do |key|
        if module_for_key(key)
          hash.send(:extend, (module_for_key(key)))
        end
      end
    end
    hash
  end

  def decorate_school(school)
    decorate_schools([school]).first
  end

  private

  def build_school_data_hash
    @query_results.each do |result|
      school_id = result[:school_id]
      state = result[:state]
      cache_value = begin Oj.load(result.value) rescue {} end

      @school_data[[state.upcase, school_id]] ||= {}
      @school_data[[state.upcase, school_id]][result.name] = cache_value
      # This breaks SchoolCacheDecorator::merged_data
      #@school_data[[state.upcase, school_id]]["_#{result.name}_updated"] = result.updated
    end
    @school_data
  end

  def module_for_key(cache_key)
    case cache_key
      when 'ratings'
        CachedRatingsMethods
      when 'metrics'
        CachedMetricsMethods
      when 'reviews_snapshot'
        CachedReviewsSnapshotMethods
      when 'esp_responses'
        CachedProgramsMethods
      when 'test_scores_gsdata'
        CachedTestScoresMethods
      when 'feed_test_scores'
        CachedFeedTestScoresMethods
      when 'nearby_schools'
        CachedNearbySchoolsMethods
      when 'performance'
        CachedPerformanceMethods
      when 'gsdata'
        CachedGsdataMethods
      when 'feed_characteristics'
        CachedFeedCharacteristicsMethods
      when 'directory'
        CachedDirectoryMethods
      when 'courses'
        CachedCoursesMethods
    end
  end

end
