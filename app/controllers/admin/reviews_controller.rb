class Admin::ReviewsController < ApplicationController

  def moderation
    if params[:review_moderation_search_string]
      moderate_by_user
      render 'reviews_for_email'
    end

    if params[:state].present? && params[:school_id].present?
      @school = School.find_by_state_and_id(params[:state], params[:school_id])
      @flagged_reviews = flagged_reviews(@school)
    else
      @flagged_reviews = flagged_reviews
    end

    gon.flagged_reviews_count = @flagged_reviews.length
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
    render 'reviews_for_email'
  end

  def moderate_by_user
    user = user_from_params
    if user
      #reviews by the user and the flags on those reviews.
      @reviews_by_user = find_reviews_by_user(user)

      #reviews that are flagged by the user.
      @reviews_flagged_by_user = find_reviews_flagged_by_user(user)
    end

    # ip = ip_from_params
    # if ip
    #   @reviews_by_user = SchoolRating.by_ip(ip)
    #   @banned_ip = BannedIp.new
    #   @banned_ip.ip = ip
    # end
  end

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

  def activate
    review = Review.find(params[:id]) rescue nil

    if review
      # Setting the moderated attribute true here allows us to save the review while bypassing some validations
      # moderated is not a db field as is not persisted
      review.moderated = true
      review.activate
      if review.save
        # TODO: Do we still need to email user?
        # email_user_about_review_removal(review)
        flash_notice 'Review activated.'
      else
        flash_error "Sorry, something went wrong while activating the review: #{review.errors.full_messages.first}"
      end
    end

    redirect_back
  end

  def deactivate
    review = Review.find(params[:id]) rescue nil

    if review
      # Setting the moderated attribute true here allows us to save the review while bypassing some validations
      # moderated is not a db field as is not persisted
      review.moderated = true
      review.deactivate
      if review.save
        # TODO: Do we still need to email user?
        # email_user_about_review_removal(review)
        flash_notice 'Review deactivated'
      else
        flash_error "Sorry, something went wrong while deactivating the review: #{review.errors.full_messages.first}"
      end
    end

    redirect_back
  end

  def resolve
    review = Review.find(params[:id]) rescue nil

    unless review
      flash_error 'Could not find review for specified review ID. No flags resolved.'
      return
    end

    review.flags.active.each do |flag|
      flag.deactivate
      unless flag.save
        flash_error "Review flag could not be resolved because of unexpected error: #{e}. Not all flags resolved."
        return
      end
    end

    flash_notice 'Review flags resolved successfully'

    redirect_back
  end

  def flag
    unless logged_in?
      flash_error 'You must be logged in to flag a review'
      redirect_back
      return
    end

    review = Review.find(params[:id]) rescue nil
    comment = params[:reason]
    reason = 'user-reported'

    if review.present? && reason.present?
      review_flag = review.build_review_flag(comment, reason)
      review_flag.user = current_user if logged_in?

      if review_flag.save
        flash_notice 'Review has been flagged'
      else
        flash_error 'Sorry, something went wrong while flagging the review.'
      end
    end

    redirect_back
  end

  protected

  def user_from_params
    search_string = params[:review_moderation_search_string]

    if search_string.present?
      search_string = search_string.strip

      User.find_by_email(search_string) if search_string.match(/[a-zA-z]/)
    end
  end

  def ip_from_params
    search_string = params[:review_moderation_search_string]

    if search_string.present?
      search_string = search_string.strip

      search_string unless search_string.match(/[a-zA-z]/)
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

  def find_reviews_flagged_by_user(user)
    user.reviews_user_flagged
  end

  def find_reviews_by_ids(review_ids)
    Review.where(id: review_ids)
  end

  def flagged_reviews(school = nil)
    if school
      partial_scope = school.reviews_scope.ever_flagged
    else
      partial_scope = Review.flagged
    end

    partial_scope.
      eager_load(:flags).
      order('review_flags.created desc').
        eager_load(:user).
        merge(User.verified).
          page(params[:page]).per(50).
            extend(SchoolAssociationPreloading).
              preload_associated_schools!
  end

  def review_params
    params.require(:review).permit(:id, notes_attributes: [:id, :notes, :_destroy])
  end

end
