class SchoolProfileReviewsPage < SitePrism::Page
  class ReviewsSection < SitePrism::Section
    elements :questions, 'form'
    elements :review_questions, '.js-topicalReviewContainer'
  end

  class ReviewQuestionVisible < SitePrism::Section
    element :question, '.bg-yellow'
    elements :responses, '.js-checkboxContainer'
    element :review_comment, '.js-topicalReviewComment'
    element :submit_button, 'button'
    element :review_form, 'form'
    elements :stars, '.js-topicalReviewStarContainer'
    elements :radio_buttons, "input[type='radio']"
    element :call_to_action_text, 'span', text: 'Have your say!'
  end

  class ReviewQuestionHidden < SitePrism::Section
    elements :review_comment, '.js-topicalReviewComment'
  end

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/reviews\/$/

  element :profile_navigation, '#navigation2'
  section :review_module, ReviewsSection, '.js-topicalReviewQuestionsContainer'
  section :visible_review_question, ReviewQuestionVisible, ".js-topicalReviewContainer.slick-active"
  element :principal_review, 'h2', text: 'School Official Point of View'
  element :active_topic_1_question, :xpath, "//div[@id='topic1'][contains(concat(' ',@class, ' '),'slick-active')]"
  element :active_topic_1_question_aria, :xpath, "//div[@id='topic1'][@aria-hidden='false']"
  element :active_topic_2_question, :xpath, "//div[@id='topic2'][contains(concat(' ',@class, ' '),'slick-active')]"
  element :active_topic_2_question_aria, :xpath, "//div[@id='topic2'][@aria-hidden='false']"
  element :role_question, '.js-roleQuestion'

  section :reviews_list_header, '.rs-review-list-header' do
    element :all_filter_button, 'button', text: 'All'
    element :parents_filter_button, 'button', text: 'Parents'
    element :students_filter_button, 'button', text: 'Students'
  end

  class ReviewSection < SitePrism::Section
    element :review_helpful_button, '.js_reviewHelpfulButton'
    element :flag_review_link, '.rs-report-review-link'
    element :review_flagged_text, 'div', text: 'You\'ve reported this review'
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
      !! text.match(/- a school leader/)
    end
  end

  sections :reviews, ReviewSection, '.js_reviewsList .cuc_review', visible: true

  def first_review
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
end


