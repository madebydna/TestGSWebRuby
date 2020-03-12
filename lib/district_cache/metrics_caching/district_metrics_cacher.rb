module MetricsCaching
  class DistrictMetricsCacher < DistrictCacher
    include DistrictCacheValidation

    CACHE_KEY = 'metrics'

    # Note: original whitelist had 445 and 446 which don't appear
    # to be valid data_type_ids, i.e. they are missing from
    # gs_schooldb.census_data_type)
    DATA_TYPE_IDS_WHITELIST = [
      370, 371, 372, 376, 392, 393, 394, 396, 398, 399, 412,
      413, 409, 414, 425, 429, 442, 443, 448, 449, 450, 454,
      462, 464, 473, 474, 476, 475, 477, 478, 479, 480, 481,
      482, 483, 484, 485, 486, 487, 488, 489
    ]

    def query_results
      @_query_results ||= begin
        results = MetricsResults.new(MetricsDistrictQuery.new(district).call.to_a)
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

    # NOTE: original district_characteristics hash had subject_id
    # but it doesn't appear to be used
    def build_hash_for_metric(metric)
      {}.tap do |hash|
        hash[:breakdown] = metric.breakdown_name
        hash[:district_value] = metric.value.to_f
        if metric.state_value
          hash[:state_average] = metric.state_value.to_f
        end
        hash[:grade] = metric.grade
        hash[:source] = metric.source_name
        hash[:subject] = metric.subject_name
        hash[:year] = metric.year
        hash[:district_created] = metric.created
      end
    end

  end
end