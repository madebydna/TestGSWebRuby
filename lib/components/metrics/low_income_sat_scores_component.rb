# frozen_string_literal: true

module Components
  module Metrics
    class LowIncomeSatScoresComponent < SatScoresComponent
      def narration
        return nil unless state && year

        if new_sat?(state, year)
          I18n.t('LI Average SAT score narration', scope: 'lib.equity_gsdata')
        else
          I18n.t('LI Average SAT score_old narration', scope: 'lib.equity_gsdata')
        end
      end

      def breakdown_percentage(value)
        value_to_s(low_income_to_percentages[value.breakdown])
      end
    end
  end
end