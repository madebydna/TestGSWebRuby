module SchoolProfiles
  module Components
    class TestScoresComponentGroup < ComponentGroup
      attr_reader :school_cache_data_reader, :components

      def initialize(school_cache_data_reader:)
        @school_cache_data_reader = school_cache_data_reader
      end

      def components
        scores = school_cache_data_reader.flat_test_scores_for_latest_year
        scores_grade_all = scores.select { | score | score[:grade] == 'All' }
        scores_grade_all = scores_grade_all.sort_by { |h| -1 * h[:number_students_tested].to_f }
        build_test_component(scores_grade_all)
      end

      def build_test_component(scores)
        scores.map { |h| h[:subject] }.uniq.map do |subject|
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

