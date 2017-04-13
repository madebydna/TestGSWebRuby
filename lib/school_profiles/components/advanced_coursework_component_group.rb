module SchoolProfiles
  module Components
    class AdvancedCourseworkComponentGroup
      attr_reader :school_cache_data_reader, :components

      def initialize(school_cache_data_reader:)
        @school_cache_data_reader = school_cache_data_reader

        @components = [
          GsdataComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
            component.data_type = 'Percentage AP enrolled grades 9-12'
            component.title = 'Percentage AP enrolled grades 9-12'
            component.type = 'person'
          end,
          GsdataComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
            component.data_type = 'Number of Advanced Courses Taken per Student'
            component.title = 'Number of Advanced Courses Taken per Student'
            component.type = 'plain'
            component.precision = 1
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

