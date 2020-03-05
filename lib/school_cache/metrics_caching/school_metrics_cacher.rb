module MetricsCaching
  class SchoolMetricsCacher < Cacher
    include CacheValidation
    CACHE_KEY = 'metrics'

    DATA_TYPE_IDS_WHITELIST = [
      365, 366, 367, 368, 369, 370, 371, 372, 373, 374, 375, 376,
      377, 378, 379, 380, 381, 382, 383, 384, 387, 388, 389, 390,
      391, 392, 393, 394, 395, 396, 397, 398, 399, 400, 401, 402,
      403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414,
      415, 416, 417, 418, 419, 420, 421, 422, 423, 424, 425, 426,
      427, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438,
      439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450,
      451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 461, 462,
      463, 464, 465, 466, 467, 468, 469, 470, 471, 472, 473, 474,
      475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 487,
      488, 489, 486, 385, 386
    ]

    def query_results
      results = MetricsResults.new(MetricsSchoolQuery.new(school).call.to_a)
      results.filter_to_max_year_per_data_type!
      results.sort_school_value_desc_by_date_type!
    end

    def build_hash_for_cache
      @_build_hash_for_cache ||= begin
        hash = {}
        query_results.each do |result|
          hash[result.label] = [] unless hash.key? result.label
          hash[result.label] << build_hash_for_metic(result)
        end
        validate!(hash)
      end
    end

    def build_hash_for_metic(metric)
      {}.tap do |hash|
        hash[:breakdown] = metric.breakdown_name
        hash[:school_value] = metric.value.to_f
        if metric.district_value
          hash[:district_average] = metric.district_value.to_f
        end
        if metric.state_value
          hash[:state_average] = metric.state_value.to_f
        end
        hash[:grade] = metric.grade
        hash[:source] = metric.source_name
        hash[:subject] = metric.subject_name
        hash[:year] = metric.year
        hash[:created] = metric.created
      end
    end

  end
end