class LocalizedProfileAjaxController < ApplicationController
  protect_from_forgery

  before_action :require_state, :require_school

  layout false

  def reviews_pagination
    offset = (params[:offset] || '0').to_i
    limit = (params[:limit] || '10').to_i
    filter_by = params[:filter_by] || nil

    active_record_relation = @school.reviews_scope
    active_record_relation = sort(active_record_relation)
    reviews = active_record_relation.to_a

    if filter_by.present? && filter_by != 'all'
      reviews.extend ReviewScoping
      reviews = reviews.by_user_type[filter_by]
    end

    school_reviews = SchoolReviews.new { reviews }.having_comments
    school_reviews = school_reviews[offset..offset + (limit - 1)]
    @school_reviews = school_reviews

    @school_reviews_helpful_counts = HelpfulReview.helpful_counts(@school_reviews)
  end

  def sort(active_record_relation)
    order = params[:order_by] || nil
    case order
      when 'oldToNew'
        active_record_relation = active_record_relation.order("reviews.created ASC")
      when 'ratingsHighToLow'
        active_record_relation = active_record_relation.order("answer_value DESC, reviews.created DESC")
      when 'ratingsLowToHigh'
        active_record_relation = active_record_relation.order("answer_value ASC, reviews.created DESC")
      else
        active_record_relation = active_record_relation.order("reviews.created DESC")
    end
    return active_record_relation
  end

end