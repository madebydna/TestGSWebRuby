class LocalizedProfileReviewsPage < LocalizedProfilePage

  # element 'navigation' inherited from LocalizedProfilePage

  elements :reviews, '.js_reviewsList .contents'
  elements :more_than_ten_reviews, '.js_reviewsList .contents'

  elements :posters, '.cuc_posted-by'

  element :parents_filter, :xpath, '//div[contains(@class, "js_reviewFilterButton")]/button[text()="Parents"]'
  element :students_filter, :xpath, '//div[contains(@class, "js_reviewFilterButton")]/button[text()="Students"]'
  element :all_filter, :xpath, '//div[contains(@class, "js_reviewFilterButton")]/button[text()="All"]'

  URLS = {
    /^.+?/ => '/profile/reviews?state=ca&schoolId=1', # any url that we know should have reviews
    /^(a )?school with more than (10|ten) reviews/ => '/profile/reviews?state=ca&schoolId=1', # any url that we know should have reviews
  }

  # return all the reviews we have if there are > 10, otherwise none
  def more_than_ten_reviews
    reviews.count > 10? reviews : nil
  end

end