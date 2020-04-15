module FeedMetricsCaching
  class FeedMetricsSchoolQuery
    attr_accessor :school

    def initialize(school)
      @school = school
    end

    def call(initial_scope = Omni::Metric.active)
      scoped = initial_scope.for_school(school)
      scoped = scoped.filter_by_data_types(SchoolFeedMetricsCacher::DATA_TYPE_IDS_WHITELIST)
      scoped = include_needed_associations(scoped)
      scoped
    end

    def include_needed_associations(scoped)
      scoped.select("metrics.*").
        includes(:subject, :breakdown, {data_set: [:data_type, :source]})
    end

  end
end