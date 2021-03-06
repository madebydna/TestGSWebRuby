# frozen_string_literal: true

module Components
  module ComponentGroups
    class AdvancedCourseworkComponentGroup < ComponentGroup
      attr_reader :cache_data_reader, :components

      def initialize(cache_data_reader:)
        cache_data_reader = cache_data_reader

        @components = [
          Components::Ratings::RatingsComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'Advanced Course Rating'
            component.title = 'Advanced courses'
            component.type = 'rating'
          end,
          GsdataComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = 'Percentage AP enrolled grades 9-12'
            component.title = 'Percentage AP enrolled grades 9-12'
            component.type = 'person'
            component.exact_breakdown_tags = ['ethnicity']
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

