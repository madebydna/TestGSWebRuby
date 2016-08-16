# require 'features/page_objects/header_section'
require 'features/page_objects/modules/breadcrumbs'
# require 'features/page_objects/modules/gs_rating'
# require 'features/page_objects/modules/modals'
# require 'features/page_objects/modules/school_profile_page'

class SchoolProfilePage < SitePrism::Page
  include Breadcrumbs
  # include GSRating
  # include Modals

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/$/

  class RatingContainer < SitePrism::Section
    element :rating, '.circle-rating--medium'
    def has_rating?(r)
      rating.text == r
    end

    sections :score_items, '.rating-score-item' do
      element :label, '.rating-score-item__label'
      element :score, '.rating-score-item__score'
      element :state_average, '.rating-score-item__state-average'
    end
  end
  
  element :gs_rating, '.rs-gs-rating'
  element :five_star_rating, '.rs-five-star-rating'
  section :test_scores, RatingContainer, '.rating-container--test-scores'

  def has_test_score_subject?(label:nil, score:nil, state_average: nil)
    score_item = self.test_scores.score_items.first
    return false unless score_item.present?

    return false if label.present? && !score_item.label.text.include?(label)
    return false if score.present? && !score_item.score.text.include?(score)
    return false if state_average.present? && !score_item.state_average.text.include?(state_average)
    return true
  end

end
