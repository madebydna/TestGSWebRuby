class Admin::ReviewsController < ApplicationController

  def moderation
    if params[:state].present? && params[:school_id].present?
      @school = School.find_by_state_and_id(params[:state], params[:school_id])
    end

    moderate_by_user

    @reported_reviews = self.flagged_reviews
    gon.reported_reviews_count = @reported_reviews.length
    @reviews_to_process = self.unprocessed_reviews
    @reported_entities = self.reported_entities_for_reviews @reported_reviews

    gon.pagename = 'Reviews moderation list'
    set_meta_tags :title =>  'Reviews moderation list'

    Admin::ReviewsController.load_reported_entities_onto_reviews(@reported_reviews, @reported_entities)
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

  def moderate_by_user

    search_string = params[:review_moderation_search_string]

    if search_string.present?
      search_string.strip!

      #TODO refactor the if and else to be more DRY

      if (search_string).match(/[a-zA-z]/)
        user = User.find_by_email(search_string)
        if user
          #reviews by the user and the flags on those reviews.
          @reviews_by_user = find_reviews_by_user(user)
          flags_for_reviews = self.reported_entities_for_reviews(@reviews_by_user) if @reviews_by_user
          Admin::ReviewsController.load_reported_entities_onto_reviews(@reviews_by_user, flags_for_reviews) if flags_for_reviews

          #reviews that are flagged by the user.
          flagged_by_user = find_reviews_reported_by_user(user)
          if flagged_by_user.present?
            @reviews_reported_by_user = find_reviews_by_ids(flagged_by_user.map(&:reported_entity_id))
            Admin::ReviewsController.load_reported_entities_onto_reviews(@reviews_reported_by_user, flagged_by_user)
          end
        end

      else
        @reviews_by_user = SchoolRating.by_ip(search_string)
        flags_for_reviews = self.reported_entities_for_reviews(@reviews_by_user) if @reviews_by_user
        Admin::ReviewsController.load_reported_entities_onto_reviews(@reviews_by_user, flags_for_reviews) if flags_for_reviews
        @banned_ip = BannedIp.new
        @banned_ip.ip = search_string
      end

      render '_reviews_for_email'
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
    review = SchoolRating.find(params[:id]) rescue nil

    if review
      review.moderated = true
      if review.update_attributes(params[:school_rating])
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

  def unprocessed_reviews
    if @school
      reviews = @school.school_ratings
    else
      reviews = SchoolRating.where(status: %w[u h])
    end

    reviews.order('posted desc').page(params[:unprocessed_reviews_page]).per(25)
  end

  def flagged_reviews
    if @school
      reviews = @school.school_ratings.ever_flagged
    else
      reviews = SchoolRating.where(status: %w[p d r a]).flagged.group(:reported_entity_id)
    end

    reviews.order('posted desc')
  end

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

  def reported_entities_for_reviews(reviews)
    ReportedEntity.find_by_reviews(reviews).order('created desc')
  end

  def email_user_about_review_removal(review)
    if review.who == 'student'
      StudentReviewHasBeenRemovedEmail.deliver_to_user(review.user, review.school)
    else
      ReviewHasBeenRemovedEmail.deliver_to_user(review.user, review.school)
    end
  end

  def find_reviews_by_user(user)
    SchoolRating.belonging_to(user)
  end

  def find_reviews_reported_by_user(user)
    ReportedEntity.where(reporter_id: user.id,reported_entity_type: "schoolReview")
  end

  def find_reviews_by_ids(review_ids)
    SchoolRating.where(id: review_ids)
  end

end
