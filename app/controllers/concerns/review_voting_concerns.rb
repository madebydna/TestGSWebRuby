module ReviewVotingConcerns
  extend ActiveSupport::Concern

  protected

  class ReviewVoting
    attr_reader :params, :user, :ip
    def initialize(params, user, ip)
      @params = params
      @user = user
      @ip = ip
    end

    def vote_for_review
      review_vote = find_or_initialize_review_vote
      review_vote.activate
      unless review_vote.save
        return review_vote, review_vote.errors.full_messages
      end
      return review_vote, nil
    end

    def unvote_review
      review_vote = find_review_vote
      if review_vote
        review_vote.deactivate
        unless review_vote.save
          return review_vote, review_vote.errors.full_messages
        end
        return review_vote, nil
      else
        return nil, ['Specified review could not be found']
      end
    end

    def find_review_vote
      review_vote = ReviewVote.find_by(vote_query_criteria)
      update_vote_attributes!(review_vote) if review_vote
      review_vote
    end

    def find_or_initialize_review_vote
      review_vote = ReviewVote.find_or_initialize_by(vote_query_criteria)
      update_vote_attributes!(review_vote)
      review_vote
    end

    def update_vote_attributes!(review_vote)
      review_vote.ipaddress = ip
    end

    def vote_query_criteria
      {
        review_id: review.id,
        member_id: user.id
      }
    end

    def review
      @review ||= (
        review_id = params[:id]
        Review.active.find_by(id: review_id)
      )
    end
  end

  def build_review_voting_object(params)
    ReviewVoting.new(params, current_user, remote_ip)
  end

  def vote_for_review_and_redirect(params)
    review_vote, errors = build_review_voting_object(params).vote_for_review
    if errors
      flash_error errors.first
    else
      flash_notice 'Your review vote has been recorded. Thanks!'
    end
    redirect_to reviews_page_for_last_school
  end

end