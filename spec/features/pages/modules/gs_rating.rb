module GSRating
  class GSRatingSection < SitePrism::Section
    elements :rating_divs, 'div:first-child'
    # This feels a bit silly to me - I'd rather rating point to a specific div, like:
    #   element :rating, '>div>div:first-child'
    # But no matter what I try, I get "SyntaxError: DOM Exception 12" when trying to make an element that accesses the
    # first child div
    def rating_value
      rating_divs.first.first('div').text
    end
  end

  def self.included(page_class)
    page_class.class_eval do
      sections :gs_rating, GSRatingSection, '.gs-rating-sm,.gs-rating-md,.gs-rating-lg'
      sections :small_gs_rating, GSRatingSection, '.gs-rating-sm'
      sections :medium_gs_rating, GSRatingSection, '.gs-rating-md'
      section :large_gs_rating, GSRatingSection, 'div.gs-rating-lg'
    end
  end
end