class Admin::SchoolsController < ApplicationController

  MODERATION_LIST_PAGE_SIZE = 50

  before_action :require_state, :require_school, except: :index

  has_scope :active, type: :boolean
  has_scope :inactive, type: :boolean
  has_scope :flagged, type: :boolean
  has_scope :has_inactive_flags, type: :boolean

  def moderate
    @held_school = @school.held_school

    @reviews = set_reviews_instance_variable

    set_meta_tags :title => page_title
    gon.pagename = 'admin_school_moderate'

    @paginate = should_paginate_reviews?
  end

  def school_reviews(school)
    relation = Review.
      where(school_id: school.id, state: school.state).
      eager_load(:answers, question: :review_topic).
      order(created: :desc)

    if params[:topic]
      relation = relation.merge(ReviewTopic.where(id: ReviewTopic.find_id_by_name(params[:topic])))
    end
    relation
  end

  def set_reviews_instance_variable
    if params[:review_id]
      reviews = Review.where(id: params[:review_id])
    else
      reviews = school_reviews(@school)
      reviews = apply_scopes(reviews).page(params[:page]).per(MODERATION_LIST_PAGE_SIZE).load
    end

    reviews.each do |review|
      review.notes.build
    end
    reviews
  end

  def page_title
   params[:review_id] ? 'Reviews moderation - review' : 'Reviews moderation - school'
  end

  def should_paginate_reviews?
    @reviews.respond_to?(:current_page)
  end

end