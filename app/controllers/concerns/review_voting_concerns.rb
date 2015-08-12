module ReviewVotingConcerns
  extend ActiveSupport::Concern

  protected

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