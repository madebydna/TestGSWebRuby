module MetricsCaching
  class MetricsSchoolQuery
    attr_accessor :school

    def initialize(school)
      @school = school
    end

    def call(initial_scope = Omni::Metric.active)
      scoped = initial_scope.for_school(school)
      scoped = scoped.filter_by_data_types(SchoolMetricsCacher::DATA_TYPE_IDS_WHITELIST)
      scoped = scoped.include_district_average(school.district_id, table_alias: 'm2')
      scoped = scoped.include_state_average(state.id, table_alias: 'm3')
      scoped = include_needed_associations(scoped)
      scoped
    end

    def include_needed_associations(scoped)
      scoped.select("metrics.*").
        includes(:subject, :breakdown, {data_set: [:data_type, :source]})
    end

    private

    def state
      @state ||= Omni::State.find_by(abbreviation: school.state)
    end
  end
end