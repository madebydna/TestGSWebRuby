class  ReviewSchoolChooserPage < SitePrism::Page

  class ReviewHighlightSection < SitePrism::Section
    element :school_link, '.link-darkgray'
  end

  section :review_highlight_section, ReviewHighlightSection, '.review-highlight'
  element :review_school_chooser_header, 'h1', text: 'Review your school!'
  element :review_highlight, '.review-highlight'
  element :review_school_chooser, '.js-autocompleteContainer'
  section :recent_reviews, '.reviews-list' do
    element :recent_reviews_header, 'h3', text: 'Recent reviews'
    elements :review_modules, '.cuc_review'
  end

  def click_on_school_link
    review_highlight_section.school_link.click
  end

end
