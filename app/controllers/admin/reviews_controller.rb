class Admin::ReviewsController < ApplicationController

  def moderation
    if params[:state].present? && params[:school_id].present?
      @school = School.find_by_state_and_id(params[:state], params[:school_id])
    end

    @reported_reviews = self.flagged_reviews
    @reviews_to_process = self.unprocessed_reviews
    @reported_entities = self.reported_entities_for_reviews @reported_reviews

    Admin::ReviewsController.load_reported_entities_onto_reviews(@reported_reviews, @reported_entities)
  end

  def update
    review = SchoolRating.find(params[:id]) rescue nil

    if review
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

  protected

  def unprocessed_reviews
    if @school
      reviews = @school.school_ratings
    else
      reviews = SchoolRating.where(status: %w[u h])
    end

    reviews.order('posted desc').page(params[:unprocessed_reviews_page]).per(5)
  end

  def flagged_reviews
    if @school
      reviews = @school.school_ratings.ever_flagged
    else
      reviews = SchoolRating.where(status: %w[p d r a]).flagged
    end

    reviews.order('posted desc').page(params[:flagged_reviews_page]).per(5)
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

end
