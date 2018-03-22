module SchoolProfiles
  module Components
    class GraduationRateComponentGroup < ComponentGroup
      attr_reader :school_cache_data_reader, :components

      def initialize(school_cache_data_reader:)
        @school_cache_data_reader = school_cache_data_reader

        @components = [
          CollegeReadinessOverall.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
            component.data_type = 'College Readiness Rating'
            component.title = 'Overview'
            component.type = 'bar'
            component.narration = I18n.t('RE UC/CSU eligibility narration', scope: 'lib.equity_gsdata')
          end,
          GraduationRateComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
            component.data_type = 'Percent of students who meet UC/CSU entrance requirements'
            component.title = 'UC/CSU eligibility'
            component.type = 'bar'
            component.narration = I18n.t('RE UC/CSU eligibility narration', scope: 'lib.equity_gsdata')
          end,
          GraduationRateComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
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

