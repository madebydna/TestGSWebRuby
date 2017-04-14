module SchoolProfiles
  module Components
    class StudentsWithDisabilitiesTestScoresComponent < TestScoresComponent
      def narration
        t('Test scores', scope: 'lib.equity_gsdata.narration.SD', subject: t(data_type))
      end
    end
  end
end
