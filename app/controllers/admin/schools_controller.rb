class Admin::SchoolsController < ApplicationController

  before_action :require_state, :require_school, except: :index

  has_scope :active, type: :boolean
  has_scope :inactive, type: :boolean
  has_scope :flagged, type: :boolean
  has_scope :has_inactive_flags, type: :boolean

  def moderate
    @held_school = @school.held_school

    if params[:review_id]
      title = 'Reviews moderation - review'
      @reviews = Review.where(id: params[:review_id])
    else
      title = 'Reviews moderation - school'
      @reviews = school_reviews(@school)
      @reviews = apply_scopes(@reviews)
      @reviews.to_a.uniq!(&:id)
    end
    @reviews.each do |review|
      review.notes.build
    end
    set_meta_tags :title => title
  end

  def school_reviews(school)
    Review.
      where(school_id: school.id, state: school.state).
      includes(:review_answers, question: :review_topic).
      order(created: :desc)
  end

end