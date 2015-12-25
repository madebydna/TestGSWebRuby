class ReviewModerationPage < SitePrism::Page
  set_url_matcher /admin\/gsr\/reviews\/moderation\/?/

  section :flagged_reviews_table, '.flagged_reviews_table' do
    sections :reviews, 'tbody tr' do
      element :comment, 'td:nth-child(1)'
      element :school_name, 'td:nth-child(3)'
      element :reason, 'td:nth-child(7)'
    end
  end

  section :reviews_flagged_by_user_table, '.reviews_flagged_by_user_table' do
    sections :reviews, 'tbody tr' do
      element :comment, 'td:nth-child(1)'
      element :school_name, 'td:nth-child(3)'
    end
  end

  section :reason_filters, 'div.rs-reason-filters' do
    element :student_filter, "input[name='student']"
    element :bad_language_filter, "input[name='bad-language']"

    def filter_on(reason)
      reason = reason.to_s.gsub('-', '_')
      filter = "#{reason}_filter"
      self.send(filter).click
    end
  end

end