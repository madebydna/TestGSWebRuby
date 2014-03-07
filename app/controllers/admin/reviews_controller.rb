class Admin::ReviewsController < ApplicationController

  has_scope :unpublished, :type => :boolean
  has_scope :provisional, :type => :boolean
  has_scope :disabled, :type => :boolean
  #has_scope :reported, :type => :boolean
  has_scope :held, :type => :boolean

  def moderation
=begin
    @reported_entities = ReportedEntity.active.
      where(reported_entity_type: %w[schoolReview topicalSchoolReview]).
      order('created desc').
      page(params[:page])

    review_ids = @reported_entities.select { |entity| entity.reported_entity_type == 'schoolReview' }
                  .map(&:reported_entity_id)
=end


    #@reported_entities = @reported_entities[0..10]

    reviews = (apply_scopes SchoolRating.reported.order("reported_entity.created DESC")).page(params[:page])

    @reported_entities = ReportedEntity.
        where(reported_entity_id: reviews.map(&:id)).
        where(reported_entity_type: %w[schoolReview]).
        order('created desc')


    @data = []

    @reported_reviews = reviews #.sort_by { |review| review_ids.index(review.id) }

    @reported_reviews.each do |review|
      #review = @reported_reviews.select { |review| review.id == entity.reported_entity_id }.first
      school = review.school
      reported_entitys = @reported_entities.select do
        |entity| entity.reported_entity_id == review.id && entity.reported_entity_type == 'schoolReview'
      end
      review.reported_entities = reported_entitys

      #if review && school
        @data << {
            reported_entity: reported_entitys.first,
            review: review,
            school: school
        }
      #end
    end
  end



end