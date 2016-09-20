module SchoolProfiles
  class ReviewQuestions

    def questions
      @_questions ||= (
        ReviewQuestion.active
      )
      @_questions.map{ |q| question_to_hash(q) }
    end

    private

    def question_to_hash(question)
      {
        response_values: question.response_array,
        response_labels: question.response_label_array,
        title: question.question,
        id: question.id,
      }
    end
  end
end
