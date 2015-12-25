class SchoolModerationPage < SitePrism::Page
  set_url_matcher /admin\/gsr\/#{States.any_state_name_regex.source}\/schools\/\d+\/moderate\/?/
  set_url "/admin/gsr/{/state}/schools/{/school_id}/moderate"

  element :reviews_topic_filter_button, '.js_reviewTopicFilterDropDownText'
  element :all_topics_filter, '.js_reviewTopicFilterDropDownText a', text: 'All topics'
  element :overall_topic_filter, '.js_reviewTopicFilterDropDownText a', text: 'Overall'

  section :school_search_form, '.rs-school-search-form' do
    element :state_dropdown, 'select'
    element :school_id_box, 'input'
    element :search_button, 'button'
  end

  class HeldSchoolSection < SitePrism::Section
    element :notes_box, 'textarea[name="held_school[notes]"]'
    element :submit_button, 'button', text: 'Put school on hold'
    element :remove_held_status_button, 'button', text: 'Remove hold (will delete notes)'

    def on_hold?
      text.match /School on hold/
    end
  end

  section :held_school_module, HeldSchoolSection, 'div.rs-held-school-container'

  class ReviewSection < SitePrism::Section
    element :comment, '.rs-review-comment'
    element :notes_box, '.rs-review-notes textarea'
    element :save_notes_button, '.rs-review-notes button', text: 'Save notes'
    element :deactivate_button, 'button', text: 'Deactivate'
    element :activate_button, 'button', text: 'Activate'
    element :resolve_flags_button, 'button', text: 'Resolve all flags'
    element :flag_review_button, 'button', text: 'Flag this review'
    element :review_answer, '.rs-review-answer'
    element :review_topic, '.rs-review-topic'

    class ReviewFlagSection < SitePrism::Section
      element :reason, 'td:nth-child(1)'
      element :flagged_on, 'td:nth-child(2)'
      element :flagged_by, 'td:nth-child(3)'
      element :comment, 'td:nth-child(4)'
    end

    sections :open_flags, ReviewFlagSection, '.rs-open-flags-table tbody tr'
    sections :resolved_flags, ReviewFlagSection, '.rs-resolved-flags-table tbody tr'

    def deactivate
      deactivate_button.click
    end

    def active?
      text.match /Status: active/
    end

    def inactive?
      text.match /Status: inactive/
    end

    def parent_review?
      !! text.match(/Affiliation: parent/)
    end

    def student_review?
      !! text.match(/Affiliation: student/)
    end

    def school_leader_review?
      !! text.match(/Affiliation: school leader/)
    end

    def review_topic_text
      review_topic.text.sub('Topic: ', '')
    end
  end

  sections :reviews, ReviewSection, '.rs-list-of-reviews div.row'

  def submit_a_review_note(note = 'Foo bar baz')
    reviews.first.notes_box.set(note)
    reviews.first.save_notes_button.click
  end

  def submit_a_school_note(note = 'Foo bar baz')
    held_school_module.notes_box.set(note)
    held_school_module.submit_button.click
  end

  def remove_school_held_status
    held_school_module.remove_held_status_button.click
  end

  def the_first_review
    reviews.first
  end

  def the_first_open_flag
    reviews.first.open_flags.first
  end

  def click_on_the_deactivate_review_button
    reviews.first.deactivate_button.click
  end

  def click_on_the_resolve_flags_button
    reviews.first.resolve_flags_button.click
  end

  def search_for_school(state, id)
    form = school_search_form
    form.state_dropdown.select(state)
    form.school_id_box.set(id)
    form.search_button.click
  end

  def reset_topic_filter
    reviews_topic_filter_button.click
    all_topics_filter.click
  end

  def filter_by_overall_topic
    reviews_topic_filter_button.click
    overall_topic_filter.click
  end

  def review_topics
    reviews.map(&:review_topic_text)
  end

end