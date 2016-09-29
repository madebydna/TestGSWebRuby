module SchoolProfiles
  class ReviewQuestions

    attr_reader :school

    def initialize(school)
      @school = school
    end

    def questions
      @_questions ||= (
        ReviewQuestion.active
      )
      @_questions.map{ |q| question_to_hash(q) }
    end

    def school_id
      school.id
    end

    def state
      school.state
    end

    private

    def question_to_hash(question)
      {
        response_values: question.response_array,
        response_labels: question.response_label_array,
        layout: question.layout,
        title: question.question,
        id: question.id,
      }
    end
  end
end
