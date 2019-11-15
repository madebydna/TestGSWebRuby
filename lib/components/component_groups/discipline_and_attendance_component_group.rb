# frozen_string_literal: true

module Components
  module ComponentGroups
    class DisciplineAndAttendanceComponentGroup < ComponentGroup
      attr_reader :cache_data_reader, :components

      def initialize(cache_data_reader:)
        @cache_data_reader = cache_data_reader
        suspension_scope = cache_data_reader.discipline_flag? ? 'disparity' : 'normal'
        attendance_scope = cache_data_reader.attendance_flag? ? 'disparity' : 'normal'
        @components = [
          GsdataComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'Percentage of students suspended out of school'
            component.title = 'Percentage of students suspended out of school'
            component.type = 'person_gray'
            component.narration = t("narration.ER.#{suspension_scope}.Percentage of students suspended out of school")
            component.flagged = cache_data_reader.discipline_flag?
            component.exact_breakdown_tags = ["ethnicity"]
            component.valid_breakdowns = []
            component.minimum_cutoff_year = 2015
          end,
          GsdataComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'Percentage of students chronically absent (15+ days)'
            component.title = 'Percentage of students chronically absent (15+ days)'
            component.type = 'person_gray'
            component.narration = t("narration.ER.#{attendance_scope}.Percentage of students chronically absent (15+ days)")
            component.flagged = cache_data_reader.attendance_flag?
            component.exact_breakdown_tags = ['ethnicity']
            component.valid_breakdowns = []
          end
        ]
        # Make sure the flagged component is visible by default when opening the group
        @components.reverse! if !@components[0].flagged && @components[1].flagged
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


