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

  def decorate_schools(schools)
    [*schools].map do |school|
      decorated = SchoolCacheDecorator.new(school, @school_data[[school.state, school.id]] || {})
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
    hash = @school_data[[state, school_id]]
    if hash
      hash.send(:extend, HashWithSchoolCacheData)
      hash.keys.each do |key|
        hash.send(:extend, (module_for_key(key)))
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
      cache_key = result[:name]
      cache_value = begin JSON.parse(result.value) rescue {} end

      @school_data[[state, school_id]] ||= {}
      @school_data[[state, school_id]][result.name] = cache_value
    end
    @school_data
  end

  def module_for_key(cache_key)
    case cache_key
      when 'ratings'
        CachedRatingsMethods
      when 'characteristics'
        CachedCharacteristicsMethods
      when 'reviews_snapshot'
        CachedReviewsSnapshotMethods
      when 'esp_responses'
        CachedProgramsMethods
      when 'progress_bar'
        CachedProgressBarMethods
      when 'test_scores'
        CachedTestScoresMethods
      when 'nearby_schools'
        CachedNearbySchoolsMethods
    end
  end

end
