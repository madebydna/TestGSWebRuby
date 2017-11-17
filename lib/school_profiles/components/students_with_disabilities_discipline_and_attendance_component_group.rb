module SchoolProfiles
  module Components
    class StudentsWithDisabilitiesDisciplineAndAttendanceComponentGroup < ComponentGroup
      attr_reader :school_cache_data_reader, :components

      def initialize(school_cache_data_reader:)
        @school_cache_data_reader = school_cache_data_reader
        @components = [
          GsdataComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
            component.data_type = 'Percentage of students suspended out of school'
            component.title = 'Percentage of students suspended out of school'
            component.type = 'person_gray'
            component.narration = t('narration.SD.Percentage of students suspended out of school')
            component.valid_breakdowns = ['All students','Students with disabilities']
          end,
          GsdataComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
            component.data_type = 'Percentage of students chronically absent (15+ days)'
            component.title = 'Percentage of students chronically absent (15+ days)'
            component.type = 'person_gray'
            component.narration = t('narration.SD.Percentage of students chronically absent (15+ days)')
            component.valid_breakdowns = ['All students','Students with IDEA catagory disabilities']
          end
        ]
      end

      def t(string, options = {})
        options = options.reverse_merge(
          scope: 'lib.equity_gsdata',
          default: I18n.t(string, default: string)
        )
        I18n.t(string, options)
      end
    end
  end
end

