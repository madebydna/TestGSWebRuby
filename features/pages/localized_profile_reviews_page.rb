class LocalizedProfileReviewsPage < LocalizedProfilePage

  # element 'navigation' inherited from LocalizedProfilePage

  elements :reviews, '.js_reviewsList .contents'
  elements /more than (\d+) reviews/, :more_than_n_reviews, '.js_reviewsList .contents'
  elements :posters, '.cuc_posted-by'

  element :parents_filter, :xpath, '//div[contains(@class, "js_reviewFilterButton")]/button[text()="Parents"]'
  element :students_filter, :xpath, '//div[contains(@class, "js_reviewFilterButton")]/button[text()="Students"]'
  element :all_filter, :xpath, '//div[contains(@class, "js_reviewFilterButton")]/button[text()="All"]'
  element :sort_reviews_dropdown, '.js_reviewFilterDropDownText'

  URLS = {
    /^.+?/ => '/profile/reviews?state=ca&schoolId=1', # any url that we know should have reviews
    /^(a )?school with more than (10|ten) reviews/ => '/profile/reviews?state=ca&schoolId=1', # any url that we know should have reviews
  }

  # return all the reviews we have if there are > 10, otherwise none
  def more_than_n_reviews(n)
    (reviews.count > n.to_i)? reviews : nil
  end

  def sort_reviews(option)
    select_box = sort_reviews_dropdown

    sort = proc {
      select_box.click
      find('li a', :text => option).click
      wait_for_reviews
    }

    if (select_box.text != option)
      (expect sort).to change{ reviews.first.text + reviews.last.text }
    else
      (expect sort).not_to change{ reviews.first.text + reviews.last.text }
    end

    select_box.text.should == option
  end

end