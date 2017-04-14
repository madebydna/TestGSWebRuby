module SchoolProfiles
  module Components
    class DisciplineAndAttendanceComponentGroup
      attr_reader :school_cache_data_reader, :components

      def initialize(school_cache_data_reader:)
        @school_cache_data_reader = school_cache_data_reader
        @components = [
          GsdataComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
            component.data_type = 'Percentage of students suspended out of school'
            component.title = 'Percentage of students suspended out of school'
            component.type = 'person_reversed'
            component.narration = t('narration.ER.Percentage of students suspended out of school')
          end,
          GsdataComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
            component.data_type = 'Percentage of students chronically absent (15+ days)'
            component.title = 'Percentage of students chronically absent (15+ days)'
            component.type = 'person_reversed'
            component.narration = t('narration.ER.Percentage of students chronically absent (15+ days)')
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

      def to_hash
        components.select(&:has_data?).each_with_object({}) do |component, accum|
          accum[t(component.title)] = component.to_hash
        end
      end
    end
  end
end

