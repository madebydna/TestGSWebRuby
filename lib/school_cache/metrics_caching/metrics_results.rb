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

    def initialize(results)
      @results = results.map {|metric| MetricDecorator.new(metric) }
    end

    def filter_to_max_year_per_data_type!
      max_years = max_year_per_data_type
      select! { |result| max_years[result.data_type_id] == result.year }
      self
    end

    def max_year_per_data_type
      data_types = results.group_by {|result| result.data_type_id }

      max_years = {}
      data_types.each do |k,v|
        # Throw out years where associated values are nil
        data_with_school_values = v.reject { |metric| metric.value.blank? }

        # Find max of remaining years
        max_year = data_with_school_values.map(&:year).max
        max_years[k] = max_year
      end

      max_years
    end

    def sort_school_value_desc_by_date_type!
      data_type_to_results = results.group_by {|result| result.data_type_id }

      # Default the sort order of rows within a data type to school_value
      # descending School value might be nil, so sort using zero in that case
      data_type_to_results.each do |k, values|
        values.sort_by! do |metric|
          metric.value.present? ? metric.value.to_f : 0
        end
        values.reverse!
      end

      @results = data_type_to_results.values.inject([], &:+)
      self
    end

  end
end