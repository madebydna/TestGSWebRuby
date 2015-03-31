class SchoolProfileReviewsPage < SitePrism::Page
  class ReviewsSection < SitePrism::Section
    elements :questions, 'form'
    elements :review_questions, '.js-topical-review-container'
  end

  class ReviewQuestion < SitePrism::Section
    elements :review_comment, '.js-gs-review-comment'
  end

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/reviews\/$/

  element :profile_navigation, '#navigation2'
  section :review_module, ReviewsSection, '.js-topicalReviewQuestionsContainer'
  section :review_question, ReviewQuestion, '.js-topical-review-container'
end


