class ReviewUsersPage < SitePrism::Page
  set_url_matcher /admin\/gsr\/reviews\/users\/?/

  section :find_by_email_or_ip_form, 'form.rs-search-by-email-and-ip-form' do
    element :search_box, 'input[name="review_moderation_search_string"]'
    element :search_button, 'button'
  end

  section :flagged_reviews_table, '.flagged_reviews_table' do
    elements :flagged_reviews, 'tbody tr'
  end

end