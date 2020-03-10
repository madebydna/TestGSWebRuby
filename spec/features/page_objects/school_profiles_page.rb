require 'features/page_objects/modules/breadcrumbs'
require 'features/page_objects/modules/join_modals'
require 'features/page_objects/modules/top_nav_section'
require 'features/page_objects/modules/reviews'
require 'features/page_objects/osp_page'

class SchoolProfilesPage < SitePrism::Page
  include Breadcrumbs
  include CookieHelper
  include EmailJoinModal
  include TopNavSection
  include Reviews

  set_url '{/state}{/city}{/school_id_and_name}/'

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

  class Students < RatingContainer
    element :ethnicity_graph, "#ethnicity-graph"
    element :subgroup_container, '.subgroups'
    elements :subgroup_data, ".subgroup"
    element :gender_data, ".gender"
  end

  class GeneralInfo < SitePrism::Section
    element :title, '.module-header .title'
    elements :tabs, ".tab-container > a"
    element :edit_link, ".title a.anchor-button"

    def tab_names
      tabs.map { |tab| tab.text }
    end

    def go_to_osp_page
      edit_link.click
      OspPage.new
    end
  end

  element :h1, 'h1'
  element :gs_rating, '.rs-gs-rating'
  element :five_star_rating, '.rs-five-star-rating'
  element :sign_in, '.account_nav_out > a'


  class HeroLinks < SitePrism::Section
    element :save_school_link, 'a.js-followThisSchool'
    element :review_link, 'a', text: "Review"
    element :nearby_schools_link, 'a', text: "Nearby schools"
  end

  section :hero, '#hero' do
    element :rating_text, '.gsr-text'
    element :rating, '.rs-gs-rating'
  end

  section :hero_links, HeroLinks, '.cta-container'

  section :test_scores, RatingContainer, '.rs-test-scores'
  section :college_readiness, RatingContainer, '#College_readiness'
  section :advanced_courses, RatingContainer, '#AdvancedCourses'
  section :advanced_stem_courses, RatingContainer, '.stem-module'
  section :equity_overview, RatingContainer, '#EquityOverview'
  section :general_information, GeneralInfo, '#General_info'
  section :race_ethnicity, RatingContainer, '#Race_ethnicity'
  section :low_income_students, RatingContainer, '#Low-income_students'
  section :students_with_disabilities, RatingContainer, '#Students_with_Disabilities'
  section :teachers_and_staff, RatingContainer, '#TeachersStaff'
  section :student_diversity, Students, '#Students,#Students-empty'
  section :homes_and_rentals, '#homes-and-rentals' do
    element :title, '.title'
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
    send("#{component}_react") if send("wait_until_#{component}_visible")
  end

  def advanced_courses_props
    props_for_react_component('Courses')
  end

  def general_information_props
    props_for_react_component('OspSchoolInfo')
  end

end
