module SchoolProfiles
  class ReviewQuestions

    attr_reader :school

    def initialize(school)
      @school = school
    end

    # The SchoolProfiles::Reviews class uses this
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

    # The SchoolProfiles::Reviews class uses this so any structural changes should be reflected there
    def question_to_hash(question)
      {
        response_values: question.response_array,
        response_labels: question.response_label_array,
        layout: question.layout,
        title: I18n.t(question.question, scope: 'lib.review_questions'),
        id: question.id,
      }
    end
  end
end
