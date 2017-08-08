module SchoolProfiles
  module Components
    class LowIncomeTestScoresComponentGroup < ComponentGroup
      attr_reader :school_cache_data_reader, :components

      VALID_BREAKDOWNS = ['All students', 'Economically disadvantaged', 'Not economically disadvantaged']

      def initialize(school_cache_data_reader:)
        @school_cache_data_reader = school_cache_data_reader
      end

      def overview
        test_score_data = LowIncomeTestScoresRatingsComponent.new.tap do |component|
          component.school_cache_data_reader = school_cache_data_reader
          component.type = 'rating'
          component.valid_breakdowns = VALID_BREAKDOWNS
        end
        test_score_data.to_hash.merge(title: t('Overview'), anchor: 'Overview') if overview_has_data?(test_score_data)
      end

      def overview_has_data?(data_values)
        data_values.values.present? && data_values.values.count > 1
      end

      def components
        school_cache_data_reader
          .flat_test_scores_for_latest_year
          .sort_by { |h| -1 * h[:number_students_tested].to_f }
          .map { |h| h[:subject] }.uniq.map do |subject|
            LowIncomeTestScoresComponent.new.tap do |component|
              component.school_cache_data_reader = school_cache_data_reader
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

