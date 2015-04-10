class SchoolModerationPage < SitePrism::Page
  set_url_matcher /admin\/gsr\/#{States.any_state_name_regex.source}\/schools\/\d+\/moderate\/?/

  section :school_search_form, '.rs-school-search-form' do
    element :state_dropdown, 'select'
    element :school_id_box, 'input'
    element :search_button, 'button'
  end

  section :held_school_module, 'div.rs-held-school-container' do
    element :notes_box, 'textarea[name="held_school[notes]"]'
    element :submit_button, 'button', text: 'Put school on hold'
    element :remove_held_status_button, 'button', text: 'Remove hold (will delete notes)'
  end

  sections :reviews, '.rs-list-of-reviews div.row' do
    element :comment, '.rs-review-comment'
    element :notes_box, 'textarea[name="school_rating[note]"]'
    element :save_notes_button, 'button', text: 'Save notes'
  end

end