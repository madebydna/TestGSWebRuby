class LocalizedProfileAjaxController < ApplicationController
  protect_from_forgery

  include SchoolParamsConcerns
  before_action :require_state, :require_school

  layout false

  def reviews_pagination
    @school_user = school_user if logged_in?
    @topic_scoped = topic_scoped?
    school_reviews = SchoolReviews.new { filtered_reviews }
    school_reviews.add_number_of_votes_method_to_each
    @filtered_school_reviews = SchoolProfileReviewsDecorator.decorate(school_reviews , view_context)
    @paginated_reviews = paginate_reviews
  end

  protected

  def school_user
    member = SchoolUser.find_by_school_and_user(@school, current_user)
    member ||= SchoolUser.build_unknown_school_user(@school, current_user)
    member
  end

  def topic_scoped?
    topic_scope = params[:filter_by_topic]
    topic_scope.present? && topic_scope != 'allTopics'
  end

  def filtered_reviews
    @filtered_reviews ||= (
    filter_by_user_type = params[:filter_by_user_type] || nil
    filter_by_topic = params[:filter_by_topic] || nil
    active_record_relation = @school.reviews_scope.order(created: :desc)
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
