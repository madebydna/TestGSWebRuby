module SchoolProfiles
  class ReviewQuestions

    def questions
      @_questions ||= (
        ReviewQuestion.active
      )
      @_questions.map{ |q| question_to_hash(q) }
    end

    # def five_star_review_question
    #   question_to_hash(questions.find(&:overall?))
    # end

    def question_to_hash(question)
      {
        response_values: question.response_array,
        response_labels: question.response_label_array,
        title: question.question,
        id: question.id,
      }.stringify_keys
    end

    # def topical_questions
    #   questions.reject(&:overall?)
    # end
  end
end
