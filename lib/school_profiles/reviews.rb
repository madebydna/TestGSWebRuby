module SchoolProfiles
  class Reviews
    include Rails.application.routes.url_helpers

    attr_reader :reviews, :school

    def initialize(school, review_questions)
      @school = school
      @reviews = school.reviews
      # review_questions is the ReviewQuestions class in lib
      # .questions is the hash of questions produced from the DB
      @review_questions = review_questions.questions
    end

    def summary
      @_summary ||= (
      OpenStruct.new.tap do |struct|
        struct.number_of_reviews = reviews.size
        struct.number_of_reviews_label = reviews.size == 1 ? 'Review' : 'Reviews'
        struct.average_five_star_rating = 
          reviews.five_star_rating_reviews.average_score.round
        struct.number_of_five_star_rating_reviews = reviews.five_star_rating_reviews.size
        struct.distribution = reviews.five_star_rating_reviews.score_distribution
        struct.topical_review_summary = reviews.topical_review_summary
        struct.topical_review_distributions = topical_review_distributions
      end)
    end

    def reviews_list
      UserReviews.
        make_instance_for_each_user(reviews.having_comments, school).
        sort_by { |r| r.most_recent_date }.
        reverse.
        map { |user_reviews| user_reviews.build_struct }
    end

    private

    def topical_review_distributions
      reviews.by_topic.each_with_object({}) do |(topic, topical_reviews), hash|
        matching_question = @review_questions.find { |q_hash| q_hash[:id] == topical_reviews.first.review_question_id }
        if matching_question
          view_hash = {
              question: matching_question[:title],
              dist: topical_reviews.extend(ReviewCalculations).score_distribution
          }
          hash[I18n.db_t(topic)] = view_hash
        end
      end
    end
  end
end
