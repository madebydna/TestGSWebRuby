# frozen_string_literal: true

module Components
  module Metrics
    class SatPercentCollegeComponent < MetricsComponent
      def narration
        if normalized_values.all? {|value| value[:grade] == 'All'}
          I18n.t('RE SAT percent college ready narration', scope: 'lib.equity_gsdata')
        else
          I18n.t('RE SAT percent college ready 11/12th narration', scope: 'lib.equity_gsdata')
        end
      end
    end
  end
end