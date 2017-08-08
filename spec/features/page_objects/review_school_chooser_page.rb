require 'features/page_objects/modules/footer'

class  ReviewSchoolChooserPage < SitePrism::Page
  include Footer

  class ReviewHighlightSection < SitePrism::Section
    element :school_link, '.link-darkgray'
  end

  section :review_highlight_section, ReviewHighlightSection, '.review-highlight'
  element :overall_topic_review_school_chooser_header, 'h1', text: 'Review your school!'
  element :gratitude_topic_review_school_chooser_header, 'h1', text: 'Are you grateful for your school?'
  element :review_highlight, '.review-highlight'
  element :review_school_chooser, '.js-autocompleteContainer'
  element :greater_good_logo_link, '.partner-logo a'
  section :recent_reviews, '.reviews-list' do
    element :recent_reviews_header, 'h3', text: 'Recent reviews'
    elements :review_modules, '.cuc_review'
  end

  def click_on_school_link
    review_highlight_section.school_link.click
  end

end
