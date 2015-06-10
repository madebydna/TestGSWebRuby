class Admin::ReviewsController < ApplicationController

  MODERATION_LIST_PAGE_SIZE = 50

  ReviewFlag::VALID_REASONS.each do |reason|
    has_scope reason, type: :boolean
  end

  def moderation
    if params[:review_moderation_search_string]
      moderate_by_user
      render 'reviews_for_email'
    end

    @flagged_reviews = flagged_reviews
    @total_number_of_reviews_to_moderate = total_number_of_reviews_to_moderate

    set_pagination_data_on_reviews(@flagged_reviews)

    gon.flagged_reviews_count = @flagged_reviews.length
    gon.pagename = 'Reviews moderation list'
    set_meta_tags :title =>  'Reviews moderation list'
  end

  def school_from_params
    @school ||= School.find_by_state_and_id(params[:state], params[:school_id])
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

  # Since we already know how many pages there must be, set this info directly on the reviews relation,
  # rather than allow Kaminari to compute it later via a "select count()" query
  def set_pagination_data_on_reviews(reviews)
    total_pages = (total_number_of_reviews_to_moderate.to_f / MODERATION_LIST_PAGE_SIZE).ceil
    reviews.define_singleton_method('total_pages') { total_pages }
  end

  def total_number_of_reviews_to_moderate
    flagged_review_ids.size
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

  # def email_user_about_review_removal(review)
  #   if review.who == 'student'
  #     StudentReviewHasBeenRemovedEmail.deliver_to_user(review.user, review.school)
  #   else
  #     ReviewHasBeenRemovedEmail.deliver_to_user(review.user, review.school)
  #   end
  # end

  def find_reviews_by_user(user)
    user.reviews
  end

  def find_reviews_flagged_by_user(user)
    user.reviews_user_flagged
  end

  def find_reviews_by_ids(review_ids)
    Review.where(id: review_ids)
  end

  def filtered_flagged_reviews_scope
    @filtered_flagged_reviews_scope ||= (
      if school_from_params
        partial_scope = school_from_params.reviews_scope.unscope(where: :active).ever_flagged
      else
        partial_scope = Review.flagged
      end

      filtered_review_flags_scope = apply_scopes(ReviewFlag)

      # If there are not active filters set for this request, the apply scopes call will return a ReviewFlag class
      # rather than ActiveRecord::Relation. In prior case, merging into our partial_scope relation will break things
      # It would be better to find out from the has_scope gem if there are any scopes set, but I looked and didn't see
      # a way
      if filtered_review_flags_scope.is_a?(ActiveRecord::Relation)
        partial_scope = partial_scope.merge(filtered_review_flags_scope)
      end

      partial_scope
    )
  end

  # Using default Kaminari methods causes extra complicated queries to be created, since it runs "count" queries
  # using the same joins / conditions present in our other queries that get actual results
  # Instead we'll compute it ourselves
  def total_number_of_items
    flagged_review_ids.size
  end

  def flagged_review_ids
    @flagged_review_ids ||= (
      # Because we only want to show the most recent inactive review for a given school/user/question combo,
      # We need to call .group and pass that list of fields, and also select the max ID for each group, assuming
      # IDs with higher values were inserted more recently
      #
      # The side effect is getting the actual Review objects requires a separate query. There might be a crafty way to
      # do it in one query but I was unsuccessful.
      #
      # Note there is currently no index on review_question_id - adding one could speed up the 'group by'
      filtered_flagged_reviews_scope.
        group('reviews.member_id, reviews.review_question_id, reviews.school_id, reviews.state').
        eager_load(:user).
        merge(User.verified).
        pluck('max(reviews.id)')
    )
  end

  def flagged_reviews
    # load needs to be called at the end of this chain, otherwise ActiveRecord will perform two extra queries
    # when extending the results and preloading the associated schools
    @flagged_reviews ||= (
      results = filtered_flagged_reviews_scope.
        where(id: flagged_review_ids).
        order('review_flags.created desc').
          includes(:user, :answers).
          page(params[:page]).per(MODERATION_LIST_PAGE_SIZE).
          load

      results.extend(SchoolAssociationPreloading).preload_associated_schools!
    )
  end

  def review_params
    params.require(:review).permit(:id, notes_attributes: [:id, :notes, :_destroy])
  end

end
