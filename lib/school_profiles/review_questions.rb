module SchoolProfiles
  class ReviewQuestions

    def questions
      ReviewQuestion.active
    end
  end
end
