class LocalizedProfileAjaxController < ApplicationController
  protect_from_forgery

  before_action :require_state, :require_school

  layout false

  def reviews_pagination
    offset = (params[:offset] || '0').to_i
    limit = (params[:limit] || '10').to_i
    filter_by_user_type = params[:filter_by_user_type] || nil
    filter_by_topic = params[:filter_by_topic] || nil

    active_record_relation = @school.reviews_scope
    reviews = active_record_relation.to_a

    if filter_by_user_type.present? && filter_by_user_type != 'all'
      reviews.extend ReviewScoping
      reviews = reviews.by_user_type[filter_by_user_type]
    end

    if filter_by_topic.present? && filter_by_topic != 'allTopics'
      reviews.extend ReviewScoping
      reviews = reviews.by_topic[filter_by_topic]
    end

    school_reviews = SchoolReviews.new { reviews }.having_comments
    @total_count = school_reviews.count
    school_reviews = school_reviews[offset..offset + (limit - 1)]
    @school_reviews = school_reviews

    @school_reviews_helpful_counts = HelpfulReview.helpful_counts(@school_reviews)


  end

end