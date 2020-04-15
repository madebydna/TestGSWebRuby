module FeedMetricsCaching
  class FeedMetricsDistrictQuery
    attr_accessor :district

    def initialize(district)
      @district = district
    end

    def call(initial_scope = Omni::Metric.active)
      scoped = initial_scope.for_district(district)
      scoped = scoped.filter_by_data_types(DistrictFeedMetricsCacher::DATA_TYPE_IDS_WHITELIST)
      scoped = include_needed_associations(scoped)
      scoped
    end

    def include_needed_associations(scoped)
      scoped.select("metrics.*").
        includes(:subject, :breakdown, {data_set: [:data_type, :source]})
    end

  end
end