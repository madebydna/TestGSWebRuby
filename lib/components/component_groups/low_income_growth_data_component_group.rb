# frozen_string_literal: true

module Components
  module ComponentGroups
    class LowIncomeGrowthDataComponentGroup < ComponentGroup
      attr_reader :cache_data_reader, :components

      def initialize(cache_data_reader:)
        @cache_data_reader = cache_data_reader

        @components =[
          Components::LowIncomeGrowthDataOverall.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = cache_data_reader.growth_type
            component.title = cache_data_reader.growth_type
            component.type = 'rating'
            component.valid_breakdowns = ['All students', 'Economically disadvantaged', 'Not economically disadvantaged']
            component.narration = t("LI #{cache_data_reader.growth_type} narration")
          end
        ]
      end

      def t(string)
        I18n.t(string, scope: 'lib.equity_gsdata', default: I18n.t(string, default: string))
      end
    end
  end
end