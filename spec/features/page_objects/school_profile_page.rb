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

  element :gs_rating, '.rs-gs-rating'
  element :five_star_rating, '.rs-five-star-rating'
  section :test_scores, '.rating-container--test-scores' do
    elements :subject_scores, '.rating-score-item'
  end

  def has_test_score_subject?(label:, value:)
    first_subject_score = self.test_scores.subject_scores.first
    return false unless first_subject_score.present?

    first_subject_score.text.include?(label) && first_subject_score.text.include?(value)
  end

end
