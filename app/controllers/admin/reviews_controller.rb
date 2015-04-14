class Admin::ReviewsController < ApplicationController

  def moderation
    if params[:state].present? && params[:school_id].present?
      @school = School.find_by_state_and_id(params[:state], params[:school_id])
    end

    # We need the reviews that are associated with the most recently created flags
    # We will paginate on the flags table
    @reported_reviews = ReportedReview.limit(10).includes(:review).group_by(&:review).keys

    gon.reported_reviews_count = @reported_reviews.length
    gon.pagename = 'Reviews moderation list'
    set_meta_tags :title =>  'Reviews moderation list'
  end

  def schools
    state = params['state']
    school_id = params['school_id']

    set_meta_tags :title =>  'Reviews moderation school search'

    if school_id.present? && state.present?
      redirect_to admin_school_moderate_path(state: States.state_name(state), school_id: school_id)
    end

  end

  def users
    set_meta_tags :title =>  'Reviews moderation user search'
    moderate_by_user
  end

  # def moderate_by_user
  #
  #   search_string = params[:review_moderation_search_string]
  #
  #   if search_string.present?
  #     search_string.strip!
  #
  #     #TODO refactor the if and else to be more DRY
  #
  #     if (search_string).match(/[a-zA-z]/)
  #       user = User.find_by_email(search_string)
  #       if user
  #         #reviews by the user and the flags on those reviews.
  #         @reviews_by_user = find_reviews_by_user(user)
  #
  #         #reviews that are flagged by the user.
  #         flagged_by_user = find_reviews_reported_by_user(user)
  #         if flagged_by_user.present?
  #           @reviews_reported_by_user = find_reviews_by_ids(flagged_by_user.map(&:reported_entity_id))
  #         end
  #       end
  #
  #     else
  #       @reviews_by_user = SchoolRating.by_ip(search_string)
  #       @banned_ip = BannedIp.new
  #       @banned_ip.ip = search_string
  #     end
  #
  #     render '_reviews_for_email'
  #   end
  # end

  def ban_ip
    if params[:banned_ip]
      ip = params[:banned_ip][:ip]
      reason = params[:banned_ip][:reason]

      banned_ip = BannedIp.find_or_initialize_by(ip: ip)
      banned_ip.reason = reason
      banned_ip.save
      flash_notice 'IP disabled.'
    end
    redirect_back
  end


  def update
    review = Review.find(params[:id]) rescue nil

    if review
      review.moderated = true
      review.notes.build if review_params['notes_attributes']
      if review.update_attributes(review_params)
        flash_notice 'Review updated.'
      else
        flash_error 'Sorry, something went wrong updating the review.'
      end
    end

    redirect_back
  end

  def publish
    review = SchoolRating.find(params[:id]) rescue nil

    if review
      # Setting the moderated attribute true here allows us to save the review while bypassing some validations
      # moderated is not a db field and is not persisted
      review.moderated = true
      review.publish!
      if review.save
        flash_notice 'Review published.'
      else
        flash_error 'Sorry, something went wrong publishing the review.'
      end
    end

    redirect_back
  end

  def disable
    review = SchoolRating.find(params[:id]) rescue nil

    if review
      # Setting the moderated attribute true here allows us to save the review while bypassing some validations
      # moderated is not a db field as is not persisted
      review.moderated = true
      review.disable!
      if review.save
        email_user_about_review_removal(review)
        flash_notice 'Review disabled.'
      else
        flash_error 'Sorry, something went wrong while disabling the review.'
      end
    end

    redirect_back
  end

  def resolve
    begin
      ReportedEntity.on_db(:community_rw)
        .where(reported_entity_id: params[:id], reported_entity_type: 'schoolReview')
        .update_all(active: false)
      flash_error 'Review resolved successfully'
    rescue => e
      flash_error "Review could not be resolved because of \
unexpected error: #{e}."
    end

    redirect_back
  end

  def report
    review = SchoolRating.find(params[:id]) rescue nil
    reason = params[:reason]

    if review.present? && reason.present?
      reported_entity = ReportedEntity.from_review(review, reason)
      if logged_in?
        reported_entity.reporter_id = current_user.id
      end

      if reported_entity.save
        flash_notice 'Review has been reported'
      else
        flash_error 'Sorry, something went wrong while reporting the review.'
      end
    end

    redirect_back
  end

  protected

  def self.load_reported_entities_onto_reviews(reviews, reported_entities)
    if reviews.present? && reported_entities.present?
      reviews.each do |review|
        entities = reported_entities.select do
          |entity| entity.reported_entity_id == review.id && entity.reported_entity_type == 'schoolReview'
        end
        review.reported_entities = entities
      end
    end
  end

  def email_user_about_review_removal(review)
    if review.who == 'student'
      StudentReviewHasBeenRemovedEmail.deliver_to_user(review.user, review.school)
    else
      ReviewHasBeenRemovedEmail.deliver_to_user(review.user, review.school)
    end
  end

  def find_reviews_by_user(user)
    user.reviews
  end

  def find_reviews_reported_by_user(user)
    user.review_flags
  end

  def find_reviews_by_ids(review_ids)
    Review.where(id: review_ids)
  end

  def review_params
    params.require(:review).permit(:id, notes_attributes: [:id, :notes, :_destroy])
  end

end
