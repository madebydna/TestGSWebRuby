module RatingsIconConcerns
  def great_schools_rating_icon
    rating = great_schools_rating || 'nr'
    rating = rating.to_s.downcase
    "<i class='iconx24-icons i-24-new-ratings-#{rating}'></i>".html_safe
  end
end