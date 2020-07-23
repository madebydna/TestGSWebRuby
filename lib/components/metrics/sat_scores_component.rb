# frozen_string_literal: true

module Components
  module Metrics
    class SatScoresComponent < MetricsComponent
      NEW_SAT_STATES = %w(ca ct mi nj co ma il)
      NEW_SAT_RANGE = (400..1600)
      OLD_SAT_RANGE = (600..2400)
      NEW_SAT_YEAR = 2016

      attr_writer :lower_range, :upper_range, :narration

      def narration
        return nil unless state && year
        return @narration if @narration.present?

        if new_sat?(state, year)
          I18n.t('RE Average SAT score narration', scope: 'lib.equity_gsdata')
        else
          I18n.t('RE Average SAT score_old narration', scope: 'lib.equity_gsdata')
        end
      end

      def lower_range
        return 0 unless normalized_values.present?

        sat_score_range.first
      end

      def upper_range
       return 100 unless normalized_values.present?

       sat_score_range.last
      end

      def new_sat?(state, year)
        NEW_SAT_STATES.include?(state.to_s.downcase) && year.to_i >= NEW_SAT_YEAR
      end

      def state
        @_state ||= cache_data_reader.school.state
      end

      def year
        @_year ||=begin
          return nil unless normalized_values.present?

          normalized_values.first[:year]
        end
      end

      def sat_score_range
        @_sat_score_range ||= new_sat?(state, year) ? NEW_SAT_RANGE : OLD_SAT_RANGE
      end
    end
  end
end