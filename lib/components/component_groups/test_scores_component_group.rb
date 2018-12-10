# frozen_string_literal: true

module Components
  module ComponentGroups
    class TestScoresComponentGroup < ComponentGroup
      attr_reader :cache_data_reader, :components

      def initialize(cache_data_reader:)
        @cache_data_reader = cache_data_reader
      end

      def overview
        test_score_data = Components::TestScores::TestScoresRatingsComponent.new.tap do |component|
          component.cache_data_reader = cache_data_reader
          component.type = 'rating'
        end
        test_score_data.to_hash.merge(title: t('Overview'), anchor: 'Overview') if overview_has_data?(test_score_data)
      end

      def overview_has_data?(ts_rating_component)
        ts_rating_component.values.present? && ts_rating_component.values.count > 1
      end

      def components
        build_test_components(
          cache_data_reader
            .recent_test_scores
            .having_grade_all
        )
      end

      def build_test_components(gs_data_values)
        gs_data_values.all_academics.map do |subject|
          Components::TestScores::TestScoresComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = subject
            component.title = I18n.t(subject, scope: 'lib.equity_test_scores', default: I18n.db_t(subject, default: subject))
            component.type = 'bar'
          end
        end
      end

      def t(string)
        I18n.t(string, scope: 'lib.equity_gsdata', default: I18n.t(string, default: string))
      end
    end
  end
end

