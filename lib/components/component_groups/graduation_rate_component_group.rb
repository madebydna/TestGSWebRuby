# frozen_string_literal: true

module Components
  module ComponentGroups
    class GraduationRateComponentGroup < ComponentGroup
      attr_reader :cache_data_reader, :components

      def initialize(cache_data_reader:)
        @cache_data_reader = cache_data_reader

        @components = [
          Components::CollegeReadinessOverall.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'College Readiness Rating'
            component.title = 'Overview'
            component.type = 'rating'
            component.narration = I18n.t('RE College readiness narration', scope: 'lib.equity_gsdata')
          end,
          Components::Metrics::SatScoresComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'Average SAT score'
            component.title = 'SAT Scores'
            component.type = 'bar_custom_range'
          end,
          Components::GraduationRates::GraduationRateComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'Percent of students who meet UC/CSU entrance requirements'
            component.title = 'UC/CSU eligibility'
            component.type = 'bar'
            component.narration = I18n.t('RE UC/CSU eligibility narration', scope: 'lib.equity_gsdata')
          end,
          Components::GraduationRates::GraduationRateComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = '4-year high school graduation rate'
            component.title = 'Graduation rates'
            component.type = 'bar'
            component.narration = I18n.t('RE Grad rates narration', scope: 'lib.equity_gsdata')
          end
        ]
      end

      def t(string)
        I18n.t(string, scope: 'lib.equity_gsdata', default: I18n.t(string, default: string))
      end
    end
  end
end


