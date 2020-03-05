module MetricsCaching
  class MetricsSchoolQuery
    attr_accessor :school

    def initialize(school)
      @school = school
    end

    def call(initial_scope = Omni::Metric.active)
      scoped = filter_by_school(initial_scope)
      scoped = filter_by_data_types(scoped)
      scoped = include_district_average(scoped)
      scoped = include_state_average(scoped)
      scoped = include_needed_associations(scoped)
      scoped
    end

    def filter_by_school(scoped)
      scoped.for_school(school)
    end

    def filter_by_data_types(scoped)
      scoped.joins(data_set: :data_type)
      .where(data_types: { id: SchoolMetricsCacher::DATA_TYPE_IDS_WHITELIST})
    end

    def include_needed_associations(scoped)
      scoped.select("metrics.*").
        includes(:subject, :breakdown, {data_set: [:data_type, :source]})
    end

    def include_district_average(scoped)
      scoped.select("m2.value as district_value").
        joins("LEFT JOIN metrics m2 ON m2.entity_type = 'district'
        AND m2.gs_id = #{school.district_id}
        AND metrics.data_set_id = m2.data_set_id
        AND metrics.breakdown_id = m2.breakdown_id
        AND metrics.subject_id = m2.subject_id
        AND metrics.grade = m2.grade")
    end

    def include_state_average(scoped)
      scoped.select("m3.value as state_value").
        joins("LEFT JOIN metrics m3 ON m3.entity_type = 'state'
        AND m3.gs_id = #{state.id}
        AND metrics.data_set_id = m3.data_set_id
        AND metrics.breakdown_id = m3.breakdown_id
        AND metrics.subject_id = m3.subject_id
        AND metrics.grade = m3.grade")
    end

    private

    def state
      @state ||= Omni::State.find_by(abbreviation: school.state)
    end
  end
end