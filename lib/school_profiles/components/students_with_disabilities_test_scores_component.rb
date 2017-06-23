module SchoolProfiles
  module Components
    class StudentsWithDisabilitiesTestScoresComponent < TestScoresComponent
      def narration
        t('Test scores', scope: 'lib.equity_gsdata.narration.SD', subject: t(data_type))
      end

      def breakdown_percentage(breakdown)
        float_value(percentage_of_students_enrolled(breakdown))
      end
    end
  end
end
