# require 'features/page_objects/header_section'
require 'features/page_objects/modules/breadcrumbs'
# require 'features/page_objects/modules/gs_rating'
# require 'features/page_objects/modules/modals'
# require 'features/page_objects/modules/school_profile_page'

class SchoolProfilesPage < SitePrism::Page
  include Breadcrumbs
  # include GSRating
  # include Modals

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/$/

  class RatingContainer < SitePrism::Section
    element :title, '.rating-container__title'
    element :rating, '.circle-rating--medium'
    def has_rating?(r)
      rating.text == r
    end

    sections :score_items, '.rating-score-item' do
      element :label, '.rating-score-item__label'
      element :score, '.rating-score-item__score'
      element :state_average, '.rating-score-item__state-average'
    end

    section :show_more, '.show-more' do
      element :more_button, '.show-more__button'
      element :items, '.show-more__items', visible: false
    end
  end

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
    elements :cta_stars, ".five-star-question-cta__star"
    element :completed_five_star_question, ".review-question > div > .five-star-rating"
    elements :questions, ".review-question"
  end

  element :gs_rating, '.rs-gs-rating'
  element :five_star_rating, '.rs-five-star-rating'
  section :test_scores, RatingContainer, '.rating-container--test-scores'
  section :college_readiness, RatingContainer, '.rs-college-readiness'
  section :review_summary, ReviewSummary, '.rs-review-summary'
  section :review_form, ReviewForm, '.review-form'

  def choose_five_star_cta_response
    review_form.cta_stars.first.click
  end

  def has_star_rating_of?(star_rating)
    five_star_rating.find_css('.filled-star').size == star_rating
  end

  def has_all_review_questions?
    review_form.questions.count == 3
  end

  def has_test_score_subject?(label:nil, score:nil, state_average: nil)
    score_item = self.test_scores.score_items.first
    return false unless score_item.present?

    return false if label.present? && !score_item.label.text.include?(label)
    return false if score.present? && !score_item.score.text.include?(score)
    return false if state_average.present? && !score_item.state_average.text.include?(state_average)
    return true
  end

end
