module MetricsCaching
  class MetricsDistrictQuery
    attr_accessor :district

    def initialize(district)
      @district = district
    end

    def call(initial_scope = Omni::Metric.active)
      scoped = initial_scope.for_district(district)
      scoped = scoped.filter_by_data_types(DistrictMetricsCacher::DATA_TYPE_IDS_WHITELIST)
      scoped = scoped.include_entity_average(type: 'state', id: state.id, table_alias: 'm2')
      include_needed_associations(scoped)
    end

    def include_needed_associations(scoped)
      scoped.select("metrics.*").
        includes(:subject, :breakdown, {data_set: [:data_type, :source]})
    end

    private

    def state
      @state ||= Omni::State.find_by(abbreviation: district.state)
    end
  end
end