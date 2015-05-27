class LocalizedProfileAjaxController < ApplicationController
  protect_from_forgery

  before_action :require_state, :require_school

  layout false

  def reviews_pagination
    @topic_scoped = topic_scoped?
    @filtered_school_reviews = SchoolProfileReviewsDecorator.decorate(
                                                        SchoolReviews.new {filtered_reviews}, view_context)
    @paginated_reviews = paginate_reviews
    # require 'pry'; binding.pry;

    @school_reviews_helpful_counts = HelpfulReview.helpful_counts(@paginated_reviews)
  end

  protected

  def topic_scoped?
    topic_scope = params[:filter_by_topic]
    topic_scope.present? && topic_scope != 'allTopics'
  end

  def filtered_reviews
    @filtered_reviews ||= (
    filter_by_user_type = params[:filter_by_user_type] || nil
    filter_by_topic = params[:filter_by_topic] || nil
    active_record_relation = @school.reviews_scope
    reviews = active_record_relation.to_a
    reviews.extend ReviewScoping
    reviews.extend ReviewCalculations
    if filter_by_user_type.present? && filter_by_user_type != 'all'
      reviews = reviews.by_user_type[filter_by_user_type]
    end

    if filter_by_topic && filter_by_topic != 'allTopics'
      reviews = reviews.by_topic[filter_by_topic]
    end
    reviews
    )
  end

  def paginate_reviews
    offset = (params[:offset] || '0').to_i
    limit = (params[:limit] || '10').to_i
    school_reviews_having_comments = SchoolReviews.new { filtered_reviews.having_comments }
    school_reviews_having_comments[offset..offset + (limit - 1)]
  end

end