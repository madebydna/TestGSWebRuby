module MetricsCaching
  class MetricsStateQuery
    attr_accessor :state_abbr

    def initialize(state_abbr)
      @state_abbr = state_abbr
    end

    def call(initial_scope = Omni::Metric.active)
      scoped = initial_scope.for_state(state)
      scoped = scoped.filter_by_data_types(StateMetricsCacher::DATA_TYPE_IDS_WHITELIST)
      scoped = include_needed_associations(scoped)
      scoped
    end

    def include_needed_associations(scoped)
      includes(:subject, :breakdown, {data_set: [:data_type, :source]})
    end

    private

    def state
      @state ||= Omni::State.find_by(abbreviation: state_abbr)
    end
  end
end