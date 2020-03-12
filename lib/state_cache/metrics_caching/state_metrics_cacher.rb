module MetricsCaching
  class StateMetricsCacher < StateCacher
    include StateCacheValidation

    CACHE_KEY = 'metrics'

    DATA_TYPE_IDS_WHITELIST = [
      365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 376, 378,
      380, 381, 382, 383, 385, 386, 396, 397, 398, 399, 401, 402,
      404, 413, 442, 443, 448, 454, 462, 464, 473, 474, 476, 475,
      477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488,
      489
    ]

    def query_results
      @_query_results ||= begin
        results = MetricsResults.new(MetricsStateQuery.new(state).call.to_a)
        results.filter_to_max_year_per_data_type!
      end
    end

    def build_hash_for_cache
      @_hash_for_cache ||= begin
        Hash.new {|h,k| h[k] = [] }.tap do |hash|
          query_results.each do |result|
            next if result.label.blank?
            hash[result.label] << build_hash_for_metric(result)
          end
        end
      end
      validate!(@_hash_for_cache)
    end

    def build_hash_for_metric
      {}.tap do |hash|
        hash[:breakdown] = metric.breakdown_name
        hash[:state_value] = metric.value.to_f
        hash[:grade] = metric.grade
        hash[:source] = metric.source_name
        hash[:subject] = metric.subject_name
        hash[:year] = metric.year
      end
    end

  end
end