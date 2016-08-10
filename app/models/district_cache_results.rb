class DistrictCacheResults

  def initialize(cache_keys, query_results)
    @cache_keys = Array.wrap(cache_keys)
    @query_results = query_results
    @district_data = {}
    build_district_data_hash
  end

  def district_data_hash
    @district_data
  end

  def decorate_districts(districts)
    [*districts].map do |district|
      decorated = DistrictCacheDecorator.new(district, @district_data[[district.state, district.id]] || {})
      @cache_keys.each do |key|
        if module_for_key(key)
          decorated.send(:extend, (module_for_key(key)))
        end
      end
      decorated
    end
  end

  module HashWithDistrictCacheData
    def cache_data
      self
    end
  end

  def get_cache_object_for_district(state, district_id)
    hash = @district_data[[state, district_id]]
    if hash
      hash.send(:extend, HashWithDistrictCacheData)
      hash.keys.each do |key|
        hash.send(:extend, (module_for_key(key)))
      end
    end
    hash
  end

  def decorate_district(district)
    decorate_districts([district]).first
  end

  private

  def build_district_data_hash
    @query_results.each do |result|
      district_id = result[:district_id]
      state = result[:state]
      cache_key = result[:name]
      cache_value = begin JSON.parse(result.value) rescue {} end

      @district_data[[state, district_id]] ||= {}
      @district_data[[state, district_id]][result.name] = cache_value
    end
    @school_data
  end

  def module_for_key(cache_key)
    case cache_key
      when 'feed_test_scores'
        DistrictCachedFeedTestScoresMethods
    end
  end

end
