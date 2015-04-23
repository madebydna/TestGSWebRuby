class SchoolProfileReviewsPage < SitePrism::Page
  class ReviewsSection < SitePrism::Section
    elements :questions, 'form'
    elements :review_questions, '.js-topical-review-container'
  end

  class ReviewQuestionVisible < SitePrism::Section
    element :question, '.bg-yellow'
    elements :responses, '.js-checkboxContainer'
    elements :review_comment, '.js-gs-review-comment'
    element :submit_button, 'button'
  end

  class ReviewQuestionHidden < SitePrism::Section
    elements :review_comment, '.js-gs-review-comment'
  end

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/reviews\/$/

  element :profile_navigation, '#navigation2'
  section :review_module, ReviewsSection, '.js-topicalReviewQuestionsContainer'
  section :visible_review_question, ReviewQuestionVisible, ".js-topical-review-container.slick-active"

  section :reviews_list, '#js_reviewsList' do
    sections :reviews, '#js_reviewsList .cuc_review' do
      element :review_helpful_button, '.js_reviewHelpfulButton'
      element :flag_review_link, '.rs-report-review-link'
      element :review_flagged_text, 'div', text: 'You\'ve reported this review'
      element :one_star, '.i-16-orange-star .i-16-star-1'
      element :two_stars, '.i-16-orange-star .i-16-star-2'
      element :three_stars, '.i-16-orange-star .i-16-star-3'
      element :four_stars, '.i-16-orange-star .i-16-star-4'
      element :five_stars, '.i-16-orange-star .i-16-star-5'
    end
  end
end


