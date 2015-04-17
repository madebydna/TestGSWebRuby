class SchoolReviews
  include Enumerable
  extend Forwardable
  def_delegators :reviews, :each, :each_with_object, :[], :blank?, :present?, :any?, :sum, :count, :select

  attr_reader :school

  # To be mixed in to an array of Reviews
  # Requires methods from Enumerable
  module ReviewCalculations
    def count_having_rating
      @count_having_rating ||= count { |review| review.answer.present? }
    end

    def average_score
      @average_score ||= count_having_rating > 0 ? sum(&:answer) / count_having_rating : 0
    end

    def total_score
      @total_score ||= sum(&:answer)
    end

    def score_distribution
      @score_distribution ||=
        group_by(&:answer).
        each_with_object({}) { |(score, answers), hash| hash[score] = answers.size }.
        compact
    end

    def rating_scores_hash
      {
        avg_score: average_score,
        total: total_score,
        counter: count_having_rating
      }
    end

    def having_comments
      select(&:has_comment?).extend ReviewCalculations
    end

    def by_user_type
      @by_user_type ||= (
        hash = group_by(&:user_type)
        hash.values.each { |array| array.extend ReviewCalculations }
        hash.freeze
      )
    end
  end

  include ReviewCalculations


  def self.build_from_cache(school, snapshot)
    school_reviews = SchoolReviews.new(school, nil)
    school_reviews.instance_variable_set(:@count, snapshot.num_reviews)
    school_reviews.instance_variable_set(:@average_score, snapshot.star_rating)
    school_reviews.instance_variable_set(:@rating_distribution, snapshot.star_counts)
    school_reviews
  end

  def initialize(school, reviews = nil)
    @school = school
    @reviews = reviews
    @reviews.extend ReviewCalculations if @reviews
  end

  def reviews
    @reviews ||= school.five_star_reviews || []
    @reviews.extend ReviewCalculations unless @reviews.respond_to?(:average_score)
    @reviews
  end

  def count
    @count ||= reviews.count
  end

  %w[parent student principal].each do |user_type|
    define_method("#{user_type}_reviews") do
      by_user_type[user_type]
    end
  end

  def principal_review
    principal_reviews.first
  end

  def has_principal_review?
    principal_reviews.present?
  end

  def review_counts_per_user_type
    {
      all: reviews.count,
      parent: parent_reviews.count,
      student: student_reviews.count
    }
  end

  def rating_scores_per_user_type
    rating_averages_per_type = Hashie::Mash.new(
      by_user_type.each_with_object({}) do |(user_type, reviews), hash|
        hash[user_type.to_sym] = reviews.rating_scores_hash
      end
    )

    rating_averages_per_type[:overall] = self.rating_scores_hash
    rating_averages_per_type
  end

  def calc_review_data
    Hashie::Mash.new(
      star_counts: reviews.score_distribution,
      rating_averages: rating_scores_per_user_type,
      review_filter_totals: review_counts_per_user_type
    )
  end

  def self.calc_review_data(reviews)
    SchoolReviews.new(nil, reviews).calc_review_data
  end

end