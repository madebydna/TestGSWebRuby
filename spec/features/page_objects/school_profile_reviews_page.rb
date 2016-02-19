require 'features/page_objects/modules/school_profile_page'

class SchoolProfileReviewsPage < SitePrism::Page
  include WaitForAjax
  include SchoolProfilePage

  class ReviewsSection < SitePrism::Section
    elements :questions, 'form'
    elements :review_questions, '.js-topicalReviewContainer'
    sections :slides, '.slick-slide:not(.slick-cloned)' do
      element :container, '.js-reviewFormContainer'

      element :question, '.bg-yellow'
      elements :responses, '.js-checkboxContainer'
      element :review_comment, '.js-topicalReviewComment', visible: false
      element :submit_button, 'button', visible: false
      element :review_form, 'form'
      element :overall_summary, '.js-overallRatingSummary'
      elements :stars, '.js-topicalReviewStarContainer'
      elements :radio_buttons, "input[type='radio']"
      element :call_to_action_text, 'span', text: 'Have your say!'

      def active?
        container.parent[:class].include?('slick-active')
      end
    end

    {
      first: 0,
      second: 1,
      third: 2,
      fourth: 3,
      fifth: 4
    }.each do |ordinal, index|
      define_method "#{ordinal}_slide" do
        slides[index]
      end
    end

    def active_slide
      slides.find(&:active?)
    end

  end

  class ReviewQuestionVisible < SitePrism::Section
    element :question, '.bg-yellow'
    elements :responses, '.js-checkboxContainer'
    element :review_comment, '.js-topicalReviewComment'
    element :submit_button, 'button'
    element :review_form, 'form'
    element :overall_summary, '.js-overallRatingSummary'
    elements :stars, '.js-topicalReviewStarContainer'
    elements :radio_buttons, "input[type='radio']"
    element :call_to_action_text, 'span', text: 'Have your say!'

  end

  class ReviewQuestionHidden < SitePrism::Section
    elements :review_comment, '.js-topicalReviewComment'
  end

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/reviews\/(#.+)?$/

  section :review_module, ReviewsSection, '#topicalReviewQuestionCarousel'
  section :visible_review_question, ReviewQuestionVisible, ".js-topicalReviewContainer.slick-active"
  element :principal_review, 'h2', text: 'School Official Point of View'

  section :role_question, '.js-roleQuestion' do
    element :parent_option, 'input[value="parent"]'
    element :submit_button, 'button', text: 'Submit'
  end

  section :reviews_list_header, '.rs-review-list-header' do
    element :all_filter_button, 'button', text: 'All'
    element :parents_filter_button, 'button', text: 'Parents'
    element :students_filter_button, 'button', text: 'Students'
    element :reviews_topic_filter_button, 'button', text: 'All topics'
    element :overall_topic_filter, 'a', text: 'Overall'
    element :teachers_topic_filter, 'a', text: 'Teachers'
  end

  class ReviewSection < SitePrism::Section
    element :vote_for_review_button, '.rs-review-voting button' # vote on helpful review
    element :unvote_review_button, '.rs-review-voting button.active'
    element :number_of_votes, '.rs-review-voting>span'
    element :flag_review_link, '.rs-report-review-link'
    element :review_flagged_text, 'div', text: 'You\'ve reported this review'
    element :stars, '.iconx16-stars'
    element :one_star, '.i-16-orange-star .i-16-star-1'
    element :two_stars, '.i-16-orange-star .i-16-star-2'
    element :three_stars, '.i-16-orange-star .i-16-star-3'
    element :four_stars, '.i-16-orange-star .i-16-star-4'
    element :five_stars, '.i-16-orange-star .i-16-star-5'
    element :posted, '.rs-review-posted'
    element :value_text, '.rs-review-value' # also contains the review topic label

    section :flag_review_form, '.rs-report-review-form' do
      element :comment_box, 'textarea[name="review_flag[comment]"]'
      element :submit_button, 'button', text: 'Submit'
      element :cancel_link, 'a', text: 'Cancel'
    end

    def number_of_votes_text
      number_of_votes.text
    end

    def posted_date
      Time.zone.parse(posted.text)
    end

    def click_on_flag_review_link
      flag_review_link.click
    end

    def submit_review_flag_comment(comment = 'Foo bar baz')
      flag_review_form.comment_box.set(comment)
      flag_review_form.submit_button.click
    end

    def parent_review?
      !! text.match(/- a parent/)
    end

    def student_review?
      !! text.match(/- a student/)
    end

    def school_leader_review?
      !! text.match(/SCHOOL LEADER/)
    end

    def overall_review?
       has_stars?
    end

    def teacher_effectiveness_review?
      !!text.match(/Teacher effectiveness/)
    end
  end

  sections :reviews, ReviewSection, '.js_reviewsList .cuc_review', visible: true

  def first_review
    wait_for_ajax
    reviews.first
  end

  def review_values
    reviews.map(&:value_text)
  end

  def review_dates
    reviews.map(&:posted_date)
  end

  def reset_filter
    reviews_list_header.all_filter_button.click
  end

  def filter_by_parents
    reviews_list_header.parents_filter_button.click
  end

  def filter_by_students
    reviews_list_header.students_filter_button.click
  end

  def filter_by_overall_topic
    reviews_list_header.reviews_topic_filter_button.click
    reviews_list_header.overall_topic_filter.click
  end

  def filter_by_teachers_topic
    reviews_list_header.reviews_topic_filter_button.click
    reviews_list_header.teachers_topic_filter.click
  end

  def vote_on_the_first_review
    wait_for_ajax
    first_review.vote_for_review_button.click
    wait_for_ajax
  end

  def unvote_the_first_review
    wait_for_ajax
    first_review.unvote_review_button.click
    wait_for_ajax
  end

  def click_third_star
    active_slide.stars[2].click
  end

  def write_a_comment(comment = 'lorem ' * 15)
    active_slide.wait_for_review_comment
    active_slide.review_comment.set(comment)
  end

  def submit_my_response
    active_slide.submit_button.click
  end

  def submit_a_comment
    write_a_comment
    submit_my_response
  end

  def active_slide
    review_module.active_slide
  end
end

