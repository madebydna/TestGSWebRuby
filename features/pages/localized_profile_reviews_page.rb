class LocalizedProfileReviewsPage < LocalizedProfilePage

  # element 'navigation' inherited from LocalizedProfilePage

  element :reviews_list, '.js_reviewsList'
  element :parents_filter, :xpath, '//div[contains(@class, "js_reviewFilterButton")]/button[text()="Parents"]'
  element :students_filter, :xpath, '//div[contains(@class, "js_reviewFilterButton")]/button[text()="Students"]'
  element :all_filter, :xpath, '//div[contains(@class, "js_reviewFilterButton")]/button[text()="All"]'

  URLS = {
    /^.+?/ => '/profile/reviews?state=ca&schoolId=1', # any url that we know should have reviews
  }

end