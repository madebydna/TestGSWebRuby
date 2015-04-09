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
end


