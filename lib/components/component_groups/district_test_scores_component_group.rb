# frozen_string_literal: true

module Components
  module ComponentGroups
    class DistrictTestScoresComponentGroup < TestScoresComponentGroup

      def overview
        nil
      end

      def build_test_components(gs_data_values)
        gs_data_values.all_academics.map do |subject|
          Components::TestScores::DistrictTestScoresComponent.new.tap do |component|
            component.cache_data_reader = cache_data_reader
            component.data_type = subject
            component.title = I18n.t(subject, scope: 'lib.equity_test_scores', default: I18n.db_t(subject, default: subject))
            component.type = 'bar'
          end
        end
      end
    end
  end
end


