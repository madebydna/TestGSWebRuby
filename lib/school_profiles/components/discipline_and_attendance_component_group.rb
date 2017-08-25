module SchoolProfiles
  module Components
    class DisciplineAndAttendanceComponentGroup < ComponentGroup
      attr_reader :school_cache_data_reader, :components

      def initialize(school_cache_data_reader:)
        @school_cache_data_reader = school_cache_data_reader
        suspension_scope = school_cache_data_reader.discipline_flag? ? 'disparity' : 'normal'
        attendance_scope = school_cache_data_reader.attendance_flag? ? 'disparity' : 'normal'
        @components = [
          GsdataComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
            component.data_type = 'Percentage of students suspended out of school'
            component.title = 'Percentage of students suspended out of school'
            component.type = 'person_reversed'
            component.narration = t("narration.ER.#{suspension_scope}.Percentage of students suspended out of school")
            component.flagged = school_cache_data_reader.discipline_flag?
          end,
          GsdataComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
            component.data_type = 'Percentage of students chronically absent (15+ days)'
            component.title = 'Percentage of students chronically absent (15+ days)'
            component.type = 'person_reversed'
            component.narration = t("narration.ER.#{attendance_scope}.Percentage of students chronically absent (15+ days)")
            component.flagged = school_cache_data_reader.attendance_flag?
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

