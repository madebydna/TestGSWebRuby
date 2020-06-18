module MetricsCaching
  class MetricsResults
    include Enumerable
    extend Forwardable
    def_delegators :@results,
                   :each,
                   :<<,
                   :select!,
                   :reject!,
                   :empty?,
                   :[],
                   :-,
                   :replace,
                   :delete,
                   :size

    attr_reader :results

    def initialize(raw_results)
      @results = combine_entity_averages!(raw_results)
    end

    # State and district values can sometimes be linked to different
    # data sets, which would cause the query to return duplicate metrics
    # records in raw_results. This method combines them back into one
    def combine_entity_averages!(raw_results)
      raw_results.group_by {|r| r.id }.map do |id, group|
        if group.length == 1
          MetricDecorator.new(group.first)
        else
          final_metric = group.first
          group.each do |m|
            if m.respond_to?(:state_value) && m.state_value.present?
              final_metric.state_value = m.state_value
            end
            if  m.respond_to?(:district_value) && m.district_value.present?
              final_metric.district_value = m.district_value
            end
          end
          MetricDecorator.new(final_metric)
        end
      end
    end

    def filter_to_max_year_per_data_type!
      max_years = max_year_per_data_type
      select! { |result| max_years[result.data_type_id] == result.year }
      self
    end

    def max_year_per_data_type
      data_type_to_results = results.group_by(&:data_type_id)

      max_years = {}
      data_type_to_results.each do |k,v|
        # Throw out years where associated values are nil
        data_with_school_values = v.reject { |metric| metric.value.blank? }

        # Find max of remaining years
        max_year = data_with_school_values.map(&:year).max
        max_years[k] = max_year
      end

      max_years
    end

    def sort_school_value_desc_by_data_type!
      data_type_to_results = results.group_by(&:data_type_id)

      data_type_to_results.each do |k, v|
        v.sort_by! { |metric| metric.value.to_f }
        v.reverse!
      end

      @results = data_type_to_results.values.inject([], &:+)
      self
    end

  end
end