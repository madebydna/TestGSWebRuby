# frozen_string_literal: true

module Components
  module ComponentGroups
    class LowIncomeGraduationRateComponentGroup < ComponentGroup
      attr_reader :cache_data_reader, :components

      def initialize(cache_data_reader:)
        @cache_data_reader = cache_data_reader

        @components = [
          Components::LowIncomeCollegeReadinessOverall.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'College Readiness Rating'
            component.title = 'Overview'
            component.type = 'rating'
            component.narration = I18n.t('LI College readiness narration', scope: 'lib.equity_gsdata')
            component.valid_breakdowns = ['All students', 'Economically disadvantaged', 'Not economically disadvantaged']
          end,
          Components::Metrics::LowIncomeSatScoresComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'Average SAT score'
            component.title = 'SAT Scores'
            component.type = 'bar_custom_range'
            component.valid_breakdowns = ['All students', 'Economically disadvantaged', 'Not economically disadvantaged']
          end,
          Components::Metrics::LowIncomeMetricsComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'Average ACT score'
            component.title = 'ACT Scores'
            component.lower_range = 1
            component.upper_range = 36
            component.narration = I18n.t('LI Average ACT score narration', scope: 'lib.equity_gsdata')
            component.type = 'bar_custom_range'
            component.valid_breakdowns = ['All students', 'Economically disadvantaged', 'Not economically disadvantaged']
          end,
          Components::Metrics::LowIncomeSatPercentCollegeComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'SAT percent college ready'
            component.title = 'SAT % college ready'
            component.type = 'bar'
            component.valid_breakdowns = ['All students', 'Economically disadvantaged', 'Not economically disadvantaged']
          end,
          Components::Metrics::LowIncomeMetricsComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'ACT percent college ready'
            component.title = 'ACT % college ready'
            component.type = 'bar'
            component.narration = I18n.t('LI ACT percent college ready narration', scope: 'lib.equity_gsdata')
            component.valid_breakdowns = ['All students', 'Economically disadvantaged', 'Not economically disadvantaged']
          end,
          Components::GraduationRates::LowIncomeGraduationRateComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'Percent of students who meet UC/CSU entrance requirements'
            component.title = 'UC/CSU eligibility'
            component.type = 'bar'
            component.valid_breakdowns = ['All students', 'Economically disadvantaged', 'Not economically disadvantaged']
          end,
          Components::GraduationRates::LowIncomeGraduationRateComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = '4-year high school graduation rate'
            component.title = 'Graduation rates'
            component.type = 'bar'
            component.valid_breakdowns = ['All students', 'Economically disadvantaged', 'Not economically disadvantaged']
          end
        ]
      end

      # ::Component::ComponentGroup
      def to_hash
        results = components.select(&:has_data?).each_with_object([]) do |component, accum|
          accum << component.to_hash.merge(title: t(component.title), anchor: component.title)
        end
        overview ? [overview].concat(results) : results
      end

      def t(string)
        I18n.t(string, scope: 'lib.equity_gsdata', default: I18n.t(string, default: string))
      end
    end
  end
end

