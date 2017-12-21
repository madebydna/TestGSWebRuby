class Api::ReviewsController < ApplicationController
  include ApiPagination
  helper_method :next, :prev

  self.pagination_max_limit = 10
  self.pagination_default_limit = 5
  # Add limit=none to query params to set limit to api_default_limit (called in api_pagination#limit)
  self.api_default_limit = 2000
  # tell the mixed-in pagination methods what code it can evaluate
  # to determine how many results were found for the current request.
  self.pagination_items_proc = proc { reviews }

  DEFAULT_FIELDS = %w[answer_value answer comment user_type created]

  def index
    render json: {
      links: {
        prev: self.prev,
        next: self.next,
      },
      items: serialized_reviews
    }
  end

  def count
    count_fields = Array.wrap(params[:fields]) & %w[review_question_id answer_value]
    relation = Review.where(criteria).active
    relation = relation.joins(:answers) if (%w[answer answer_value] & count_fields).present?
    result = relation.group(count_fields).count
    render json: { result: result }
  end

  def serialized_reviews
    reviews.map do |obj|
      Api::ReviewSerializer.new(obj).to_hash.tap do |o|
        o.except(DEFAULT_FIELDS - fields)
      end
    end
  end

  def reviews
    # If you need to change this query, you might find code in
    # school_review_concerns.rb useful
    @_reviews ||= (
      relation = Review
        .where(criteria)
        .active
        .offset(offset)
        .limit(limit)
        .order(:created)

      relation.eager_load(:school_user) if fields.include?('user_type')
      relation.includes(:answers) if (%w[answer answer_value] & fields).present?
      relation
    )
  end

  def criteria
    params.slice(:review_question_id, :state, :school_id)
  end

  def fields
    Array.wrap(params[:fields]).presence || DEFAULT_FIELDS
  end

  def all_commented_reviews
    Review.
      active.
      where(school_id: params[:school_id], state: params[:state]).
      eager_load(:school_user).
      includes(:answers, :votes, question: :review_topic).
      order(created: :desc).
      to_a.
      extend(ReviewScoping).
      extend(ReviewCalculations).
      having_comments
  end

  def reviews_list
    all_reviews = (
    UserReviews.
      make_instance_for_each_user(all_commented_reviews, School.on_db(params[:state].downcase).find(params[:school_id].to_i)).
      sort_by { |r| r.most_recent_date }.
      reverse.
      map { |user_reviews| user_reviews.build_struct }
    )
    render json: all_reviews
  end
end
