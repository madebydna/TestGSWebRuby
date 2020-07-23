# frozen_string_literal: true

module Components
  module Metrics
    class LowIncomeSatScoresComponent < SatScoresComponent
      def breakdown_percentage(value)
        value_to_s(low_income_to_percentages[value.breakdown])
      end
    end
  end
end