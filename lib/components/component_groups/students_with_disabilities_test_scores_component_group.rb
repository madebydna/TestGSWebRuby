# frozen_string_literal: true

module Components
  module ComponentGroups
    class StudentsWithDisabilitiesTestScoresComponentGroup < ComponentGroup
      attr_reader :cache_data_reader, :components

      def initialize(cache_data_reader:)
        @cache_data_reader = cache_data_reader
      end

      def components
        cache_data_reader
          .recent_test_scores
          .all_academics.map do |subject|
            Components::TestScores::StudentsWithDisabilitiesTestScoresComponent.new.tap do |component|
              component.cache_data_reader = cache_data_reader
              component.data_type = subject
              component.title = I18n.t(subject, scope: 'lib.equity_test_scores', default: I18n.db_t(subject, default: subject))
              component.type = 'bar'
              component.valid_breakdowns = ['All students','Students with disabilities']
            end
          end
      end

      def t(string)
        I18n.t(string, scope: 'lib.equity_gsdata', default: I18n.t(string, default: string))
      end
    end
  end
end

