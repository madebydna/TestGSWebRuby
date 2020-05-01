module FeedMetricsCaching
  class DistrictFeedMetricsCacher < DistrictCacher
    include DistrictCacheValidation

    CACHE_KEY = 'feed_metrics'

    # 365: Percentage of teachers in their first year
    # 366: Bachelor's degree
    # 367: Master's degree
    # 368: Doctorate's degree
    # 369: Students Per Teacher
    # 370: Students participating in free or reduced-price lunch program
    # 371: English learners
    # 372: Ethnicity
    # 373: Average years of teacher experience
    # 374: Students who are economically disadvantaged
    # 376: Enrollment
    # 378: Other degree
    # 380: Master's degree or higher
    # 381: Average years of teaching in district
    # 382: Teaching experience 0-3 years
    # 383: Percent classes taught by non-highly qualified teachers
    # 385: Head official name
    # 386: Head official email address
    # 397: At least 5 years teaching experience
    # 398: Female
    # 399: Male
    # 401: Teachers with no valid license
    # 402: Percent classes taught by highly qualified teachers
    # 404: Teachers with valid license

    DATA_TYPE_IDS_WHITELIST = [
      365, 366, 367, 368, 369, 370, 371, 372, 373,
      374, 376, 378, 380, 381, 382, 383, 385, 386,
      397, 398, 399, 401, 402, 404
    ]

    def self.listens_to?(data_type)
      data_type == :feed_metrics
    end

    def query_results
      results = MetricsCaching::MetricsResults.new(
        FeedMetricsDistrictQuery.new(district).call.to_a
      )
      results.filter_to_max_year_per_data_type!
      results.sort_school_value_desc_by_data_type!
    end

    def build_hash_for_cache
      @_build_hash_for_cache ||= begin
        hash = {}
        query_results.each do |result|
          hash[result.label] = [] unless hash.key? result.label
          hash[result.label] << build_hash_for_metric(result)
        end
        validate!(hash)
      end
    end

    def build_hash_for_metric(metric)
      {}.tap do |hash|
        hash[:breakdown] = metric.breakdown_name
        hash[:district_created] = metric.created
        hash[:grade] = metric.grade
        hash[:district_value] = Float(metric.value) rescue metric.value
        hash[:source] = metric.source_name
        hash[:year] = metric.year
      end
    end

    def self.active?
      ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
    end
  end
end