module SchoolProfiles
  module Components
    class AdvancedCourseworkComponentGroup < ComponentGroup
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
    end
  end
end

