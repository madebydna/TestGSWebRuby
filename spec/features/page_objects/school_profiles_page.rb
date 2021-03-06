# require 'features/page_objects/header_section'
require 'features/page_objects/modules/breadcrumbs'
# require 'features/page_objects/modules/gs_rating'
# require 'features/page_objects/modules/modals'
# require 'features/page_objects/modules/school_profile_page'

class SchoolProfilesPage < SitePrism::Page
  include Breadcrumbs
  include CookieHelper

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/$/

  class RatingContainer < SitePrism::Section
    element :title, '.module-header .title'
    element :rating, '.circle-rating--medium'
    element :source_link, 'a', text: 'Sources'
    def has_rating?(r)
      rating.text == r
    end

    sections :score_items, '.bar-graph-display' do
      element :label, '.subject'
      element :score, '.score'
      element :state_average, '.state-average'
    end

    sections :test_score_items, '.test-score-container' do
      element :label, '.subject'
      element :score, '.score'
      element :state_average, '.state-average'
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
    elements :text_areas, "textarea"
    element :submit, ".button.cta"
    def submit_form
        submit.click
    end
  end

  class Students < RatingContainer
    element :ethnicity_graph, "#ethnicity-graph"
    element :subgroup_container, '.subgroups'
    elements :subgroup_data, ".subgroup"
    element :gender_data, ".gender"
  end

  class ReviewList < SitePrism::Section
    element :five_star_review_comment, ".five-star-review .comment"
    element :five_star_review
    section :five_stars, FiveStars, '.five-stars'

    def has_five_star_comment?(comment)
      five_star_review_comment.text == comment
    end
  end

  element :h1, 'h1'
  element :gs_rating, '.rs-gs-rating'
  element :five_star_rating, '.rs-five-star-rating'
  element :sign_in, '.account_nav_out > a'

  section :hero, '#hero' do
    element :rating_text, '.gsr-text'
  end

  section :test_scores, RatingContainer, '.rs-test-scores'
  section :college_readiness, RatingContainer, '#College_readiness'
  section :advanced_courses, RatingContainer, '#AdvancedCourses'
  section :advanced_stem_courses, RatingContainer, '.stem-module'
  section :equity_overview, RatingContainer, '#EquityOverview'
  section :general_information, RatingContainer, '#General_info'
  section :race_ethnicity, RatingContainer, '#Race_ethnicity'
  section :low_income_students, RatingContainer, '#Low-income_students'
  section :students_with_disabilities, RatingContainer, '#Students_with_Disabilities'
  section :students, '.students-container' do

  end
  section :teachers_and_staff, RatingContainer, '#TeachersStaff'

  section :student_diversity, Students, '.students-container'
  section :review_summary, ReviewSummary, '.rs-review-summary'
  section :review_form, ReviewForm, '.review-form'
  section :review_list, ReviewList, '.review-list'
  section :homes_and_rentals, '#homes-and-rentals' do
    element :title_bar, '.title-bar'
  end
  section :neighborhood, '.neighborhood-module' do

  end

  section :equity, '.rs-equity' do
    element :source_link, 'a', text: 'see notes'
  end
  section :nearby_schools, '.nearby-schools' do
    element :title, '.title'
    elements :schools, '.nearby-school'
  end

  element :five_star_review_comment, ".five-star-review .comment"

  def choose_five_star_cta_response(star_select = 1)
    index = star_select - 1
    review_form.cta_stars[index].click
  end

  def fill_in_five_star_rating_comment(comment)
    review_form.text_areas.last.set comment
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

  def has_test_score_subject?(label:nil, score:nil, state_average: nil)
    test_score_items = self.test_scores.test_score_items.second # because of column headers
    return false unless test_score_items.present?

    return false if label.present? && !test_score_items.label.text.include?(label)
    return false if score.present? && !test_score_items.score.text.include?(score)
    return false if state_average.present? && !test_score_items.state_average.text.include?(state_average)
    return true
  end

  def props_for_react_component(component)
    node = page.find('div.js-react-on-rails-component[data-component-name="' + component + '"]', visible: false)
    return {} unless node
    props_as_string = node['data-props']
    return {} unless props_as_string.present?
    JSON.parse(props_as_string)
  end

  # This approach could work too
  #   dom_id = page.evaluate_script("$('[data-component-name=#{component}]').data('dom-id')")
  #   ::SitePrism::Waiter.wait_until_true do
  #     page.evaluate_script("$('##{dom_id}').html().length > 0")
  #   end
  def wait_for_react_component(component)
    dom_id = page.evaluate_script("$('[data-component-name=#{component}]').data('dom-id')")
    singleton_class.send(:element, "#{component}_react", "##{dom_id}")
    send("#{component}_react") if send("wait_for_#{component}_react")
  end

  def advanced_courses_props
    props_for_react_component('Courses')
  end

  def general_information_props
    props_for_react_component('OspSchoolInfo')
  end

  def submit_a_valid_5_star_rating_comment
    choose_five_star_cta_response(5)
    fill_in_five_star_rating_comment(valid_comment)
    review_form.submit_form
  end

  def valid_comment
    'A valid and wonderful comment on a school yeah!'
  end

end
