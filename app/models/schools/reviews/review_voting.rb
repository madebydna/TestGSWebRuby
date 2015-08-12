class ReviewVoting
  attr_accessor :errors
  attr_reader :params, :user, :ip
  def initialize(params, user, ip)
    @params = params
    @user = user
    @ip = ip
    @errors = []
  end

  def valid?
    validate_not_own_review
  end

  def validate_not_own_review
    if user.reviews.active.include?(review)
      @errors << 'Sorry, you may not vote on your own review.'
      return false
    end
    return true
  end

  def vote_for_review
    return nil, errors unless valid?

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