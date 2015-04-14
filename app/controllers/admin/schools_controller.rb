class Admin::SchoolsController < ApplicationController

  before_action :require_state, :require_school, except: :index

  has_scope :active, type: :boolean
  has_scope :inactive, type: :boolean

  def moderate
    @held_school = @school.held_school

    if params[:review_id]
      title = 'Reviews moderation - review'
      @reviews = Review.where(id: params[:review_id])
    else
      title = 'Reviews moderation - school'
      @reviews = @school.reviews
      @reviews = apply_scopes(@reviews)
      @reviews.to_a.uniq!(&:id)
    end
    @reviews.each do |review|
      review.notes.build
    end
    set_meta_tags :title => title
  end

end