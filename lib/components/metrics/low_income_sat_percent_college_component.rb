# frozen_string_literal: true

module Components
  module Metrics
    class LowIncomeSatPercentCollegeComponent < MetricsComponent
      def narration
        if normalized_values.all? {|value| value[:grade] == 'All'}
          I18n.t('LI SAT percent college ready narration', scope: 'lib.equity_gsdata')
        else
          I18n.t('LI SAT percent college ready 11/12th narration', scope: 'lib.equity_gsdata')
        end
      end
      
      def breakdown_percentage(value)
        value_to_s(low_income_to_percentages[value.breakdown])
      end
    end
  end
end