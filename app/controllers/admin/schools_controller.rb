class Admin::SchoolsController < ApplicationController

  before_filter :require_state, :require_school, except: :index

  has_scope :unpublished, :type => :boolean
  has_scope :provisional, :type => :boolean
  has_scope :disabled, :type => :boolean
  has_scope :reported, :type => :boolean
  has_scope :held, :type => :boolean

  def moderate
    @held_school = @school.held_school
    review_id = params[:review_id]

    if review_id
      @reviews = SchoolRating.where(id: review_id)
    else
      @reviews = SchoolRating.where(state: @school.state, school_id: @school.id).order(created: :desc)
      @reviews = apply_scopes(@reviews)
    end

    reported_entities = @reported_entities = ReportedEntity.
        where(reported_entity_id: @reviews.map(&:id) ).
        where(reported_entity_type: %w[schoolReview topicalSchoolReview]).
        order(created: :desc)

    @reviews.each do |review|
      review.reported_entities = reported_entities.select { |entity| entity.reported_entity_id == review.id } || []
    end
  end

end