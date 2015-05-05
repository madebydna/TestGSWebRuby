class ReviewModerationPage < SitePrism::Page
  set_url_matcher /admin\/gsr\/reviews\/moderation\/?/

  section :flagged_reviews_table, '.flagged_reviews_table' do
    sections :reviews, 'tbody tr' do
      element :comment, 'td:nth-child(1)'
      element :school_name, 'td:nth-child(3)'
    end
  end

  section :reviews_flagged_by_user_table, '.reviews_flagged_by_user_table' do
    sections :reviews, 'tbody tr' do
      element :comment, 'td:nth-child(1)'
      element :school_name, 'td:nth-child(3)'
    end
  end

end