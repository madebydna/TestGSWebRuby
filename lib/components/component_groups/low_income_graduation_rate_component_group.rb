# frozen_string_literal: true

module Components
  module ComponentGroups
    class LowIncomeGraduationRateComponentGroup < ComponentGroup
      attr_reader :cache_data_reader, :components

      def initialize(cache_data_reader:)
        @cache_data_reader = cache_data_reader

        @components = [
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

      def t(string)
        I18n.t(string, scope: 'lib.equity_gsdata', default: I18n.t(string, default: string))
      end
    end
  end
end

