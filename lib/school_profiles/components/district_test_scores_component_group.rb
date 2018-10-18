# frozen_string_literal: true

module SchoolProfiles
  module Components
    class DistrictTestScoresComponentGroup < TestScoresComponentGroup

      def overview
        nil
      end

      def build_test_components(gs_data_values)
        gs_data_values.all_academics.map do |subject|
          DistrictTestScoresComponent.new.tap do |component|
            component.school_cache_data_reader = school_cache_data_reader
            component.data_type = subject
            component.title = I18n.t(subject, scope: 'lib.equity_test_scores', default: I18n.db_t(subject, default: subject))
            component.type = 'bar'
            component.valid_breakdowns = ["Hispanic",
                                          "White",
                                          "African American",
                                          "Black",
                                          "Two or more races",
                                          "Multiracial",
                                          "Asian or Pacific Islander",
                                          "Asian",
                                          "American Indian/Alaska Native",
                                          "Native American",
                                          "Native American or Native Alaskan",
                                          "Pacific Islander",
                                          "Hawaiian Native/Pacific Islander",
                                          "Native Hawaiian or Other Pacific Islander",
                                          "All students"]
          end
        end
      end
    end
  end
end


