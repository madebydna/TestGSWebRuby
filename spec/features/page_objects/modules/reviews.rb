module Reviews

  class FiveStars < SitePrism::Section
    def filled
      root_element.all('.filled-star').count
    end
  end

  class ReviewSummary < SitePrism::Section
    element :number_of_reviews, '.number-of-reviews .count'
    element :number_of_reviews_label, '.number-of-reviews .label'
    section :five_stars, FiveStars, '.five-stars'
  end

  class ReviewForm < SitePrism::Section
    element :five_star_question_cta, ".five-star-question-cta"
    elements :cta_star_containers, ".five-star-question-cta__response-container"
    elements :cta_stars, ".five-star-question-cta__star"
    element :five_star_rating, :xpath, './div/div/div[2]/div[6]/div/div[1]'
    element :completed_five_star_question, ".review-question > div > .five-star-rating"
    element :review_questions_container, ".review-questions"
    elements :questions, ".review-question"
    elements :text_areas, "textarea"
    element :submit, ".button.cta"

    def rate_your_experience_textarea
      questions.last.find('textarea')
    end

    def submit_form
      submit.click
    end
  end

  class UserReview < SitePrism::Section
    element :user_type, ".user-info-column .user-type"
    element :five_star_review_comment, ".five-star-review .comment"
    element :five_star_review
    section :five_stars, FiveStars, '.five-stars'

    def has_five_star_comment?(comment)
      five_star_review_comment.text == comment
    end
  end

  class ReviewList < SitePrism::Section
    element :message, ".submit-review-message"
    sections :user_reviews, UserReview, ".user-reviews-container"
  end

  def self.included(page_class)
    page_class.class_eval do
      section :review_summary, ReviewSummary, '.rs-review-summary'
      section :review_form, ReviewForm, '.review-form'
      section :review_list, ReviewList, '.review-list'

      def choose_five_star_cta_response(star_select = 1)
        index = star_select - 1
        review_form.cta_star_containers[index].find('.five-star-question-cta__response-label', visible: false).click
      end

      def fill_in_five_star_rating_comment(comment)
        review_form.rate_your_experience_textarea.set comment
      end

      def has_star_rating_of?(star_rating)
        five_star_rating.find_css('.filled-star').size == star_rating
      end

      def five_star_rating_value
        five_star_rating.find_css('.filled-star').size
      end

      def gs_rating_value
        gs_rating.text.to_i
      end

      def has_all_review_questions?
        review_form.questions.count == 3
      end

      def submit_a_valid_5_star_rating_comment(comment: valid_comment)
        choose_five_star_cta_response(5)
        wait_until_review_form_visible(wait: 5)
        review_form.wait_until_questions_visible(wait: 5)
        fill_in_five_star_rating_comment(comment)
        review_form.submit_form
      end

      def valid_comment
        "A valid and wonderful comment on a school yeah! - #{Time.now}"
      end

      def define_relationship_to_school(relationship: :parent)
        wait_until_relationship_to_school_modal_visible(wait: 10)
        relationship_to_school_modal.send(relationship).click
        relationship_to_school_modal.submit_button.click
        sleep(5)
      end
    end
  end
end