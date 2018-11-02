# frozen_string_literal: true

module Components
  module TestScores
    class StudentsWithDisabilitiesTestScoresComponent < TestScoresComponent
      def narration
        subject = t(data_type)
        t('Test scores',
          scope: 'lib.equity_gsdata.narration.SD',
          subject: subject,
          count: count_of_initial_vowels(subject))
      end

      # This allows our translations file to specify a different article depending on whether the subject
      # starts with a vowel or not. e.g. "an English" versus "a Math"
      def count_of_initial_vowels(word)
        [word[0]].count { |c| %w(a e i o u).include?(c.downcase) }
      end

      def breakdown_percentage(breakdown)
        float_value(percentage_of_students_enrolled(breakdown))
      end
    end
  end
end
