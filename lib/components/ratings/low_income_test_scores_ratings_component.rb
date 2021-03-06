# frozen_string_literal: true

module Components
  module Ratings
    class LowIncomeTestScoresRatingsComponent < Component

      def narration
        rating = cache_data_reader.equity_ratings_breakdown('Economically disadvantaged')
        narration_rating = narration_key(rating)
        t(narration_rating, scope: 'lib.equity_gsdata.LI Test scores overview narration',
          subject: t(data_type), more: SchoolProfilesController.show_more('Low income'),
          end_more: SchoolProfilesController.show_more_end) # TODO: update scope after moving translations
      end

      def narration_key(rating)
        if rating
          "_#{((rating.to_i + 1) / 2).floor}_html"
        else
          '_0_html'
        end
      end

      def normalized_values
        @_normalized_values ||= (
          cache_data_reader.test_scores_all_rating_hash
              .map { |h| cache_hash_to_standard_hash(h) }
        )
      end

      def values
        @_values ||= (
          normalized_values.select {|h| rating_has_valid_data?(h)}
              .map { |h| standard_hash_to_value_hash_ratings(h) }
              .sort(&method(:comparator))
        )
      end

      def comparator(h1, h2)
        return -2 if h1[:breakdown] == 'All students'
        return 2 if h2[:breakdown] == 'All students'
        return -1 if h1[:breakdown] == 'Economically disadvantaged'
        return 1 if h2[:breakdown] == 'Economically disadvantaged'
        return h2[:percentage].to_f <=> h1[:percentage].to_f
      end

      def cache_hash_to_standard_hash(hash)
        # Dont mutate hash that is passed in
        hash.merge(
          'percentage' => breakdown_percentage(hash['breakdown']),
          'breakdown' => hash['breakdown'].nil? ? 'All students' : hash['breakdown']
        )
      end
      #
      def breakdown_percentage(breakdown)
        value_to_s(low_income_to_percentages[breakdown])
      end
    end
  end
end
