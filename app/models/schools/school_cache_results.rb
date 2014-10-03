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
    schools.map do |school|
      decorated = SchoolCacheDecorator.new(school, @school_data[[school.state, school.id]] || {})
      @cache_keys.each do |key|
        decorated.send(:extend, (module_for_key(key)))
      end
      decorated
    end
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
    end
  end

end