# frozen_string_literal: true

module Components
  module ComponentGroups
    class LowIncomeTestScoresComponentGroup < ComponentGroup
      attr_reader :cache_data_reader, :components

      VALID_BREAKDOWNS = ['All students', 'Economically disadvantaged', 'Not economically disadvantaged']

      def initialize(cache_data_reader:)
        @cache_data_reader = cache_data_reader
      end

      def overview
        test_score_data = Components::Ratings::LowIncomeTestScoresRatingsComponent.new.tap do |component|
          component.cache_data_reader = cache_data_reader
          component.type = 'rating'
          component.valid_breakdowns = VALID_BREAKDOWNS
        end
        test_score_data.to_hash.merge(title: t('Overview'), anchor: 'Overview') if overview_has_data?(test_score_data)
      end

      def overview_has_data?(data_values)
        data_values.values.present? && data_values.values.count > 1
      end

      def components
        cache_data_reader
          .recent_test_scores
          .all_academics.map do |subject|
            Components::TestScores::LowIncomeTestScoresComponent.new.tap do |component|
              component.cache_data_reader = cache_data_reader
              component.data_type = subject
              component.title = I18n.t(subject, scope: 'lib.equity_test_scores', default: I18n.db_t(subject, default: subject))
              component.type = 'bar'
              component.valid_breakdowns = VALID_BREAKDOWNS
            end
          end
      end

      def t(string)
        I18n.t(string, scope: 'lib.equity_gsdata', default: I18n.t(string, default: string))
      end
    end
  end
end

