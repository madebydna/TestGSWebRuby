# frozen_string_literal: true

module Components
  module Metrics
    class SatScoresComponent < Component
      NEW_SAT_STATES = %w(ca ct mi nj co ma il)
      NEW_SAT_RANGE = (400..1600)
      OLD_SAT_RANGE = (600..2400)
      NEW_SAT_YEAR = 2016

      def narration
        year = normalized_values.first.fetch(:year, nil)
        state = cache_data_reader.school.state
        
        if new_sat?(state, year)
          I18n.t('RE Average SAT score narration', scope: 'lib.equity_gsdata')
        else
          I18n.t('RE Average SAT score_old narration', scope: 'lib.equity_gsdata')
        end
      end

      def normalized_values
        @normalized_values ||=
          cache_data_reader.decorated_metrics_data(data_type)
                           .having_most_recent_date
                           .no_subject_or_all_subjects
                           .having_all_students_or_breakdown_in(valid_breakdowns)
                           .map { |h| cache_hash_to_standard_hash(h) }
      end

      def cache_hash_to_standard_hash(hash)
        breakdown = hash['breakdown']
        {
          breakdown: breakdown,
          score: hash['school_value'],
          state_average: hash['state_average'],
          percentage: ethnicities_to_percentages[breakdown],
          year: hash['year'] || ((hash['source_date_valid'] || '')[0..3]).presence || hash['source_year']
        }
      end

      def standard_hash_to_value_hash(h)
        {
          breakdown: t(h[:breakdown]),
          label: text_value(h[:score]),
          score: h[:score],
          lower_range: sat_score_range(cache_data_reader.school.state, h[:year])&.first,
          upper_range: sat_score_range(cache_data_reader.school.state, h[:year])&.last,
          state_average: h[:state_average],
          state_average_label: value_to_s(h[:state_average]),
          display_percentages: true,
          percentage: value_to_s(h[:percentage]),
          visualization: 'bar_custom_range',
        }
      end

      def new_sat?(state, year)
        NEW_SAT_STATES.include?(state.to_s.downcase) && year.to_i >= NEW_SAT_YEAR
      end

      def sat_score_range(state, year)
        new_sat?(state, year) ? NEW_SAT_RANGE : OLD_SAT_RANGE
      end
    end
  end
end