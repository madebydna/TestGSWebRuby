module CommunityProfiles
  class ReviewQuestions
    attr_reader :Community

    def initialize(community)
      @community = community
    end

    # The CommunityProfiles::Reviews class uses this
    def questions
      @_questions ||= (
        ReviewQuestion.active.map{ |q| question_to_hash(q) }
      )
    end

    def community_id
      community.id
    end

    def state
      community.state
    end

    private

    # The CommunityProfiles::Reviews class uses this so any structural changes should be reflected there
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
