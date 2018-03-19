module SchoolProfiles
  module Components
    class TestScoresComponentGroup < ComponentGroup
      attr_reader :school_cache_data_reader, :components

      def initialize(school_cache_data_reader:)
        @school_cache_data_reader = school_cache_data_reader
      end

      def overview
        test_score_data = TestScoresRatingsComponent.new.tap do |component|
          component.school_cache_data_reader = school_cache_data_reader
          component.type = 'rating'
        end
        test_score_data.to_hash.merge(title: t('Overview'), anchor: 'Overview') if overview_has_data?(test_score_data)
      end

      def overview_has_data?(data_values)
        data_values.values.present? && data_values.values.count > 1
      end

      def components
        build_test_components(
          school_cache_data_reader
            .flat_test_scores_for_latest_year
            .having_grade_all
            .sort_by_cohort_count
        )
      end

      def build_test_components(gs_data_values)
        gs_data_values.all_academics.map do |subject|
          TestScoresComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
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

