class DistrictBoundariesController < ApplicationController
  layout "application"

  def show
    set_seo_meta_tags
  end

  def meta_title
    'School and District Boundaries Map | GreatSchools'
  end

  def meta_description
    'Enter zip code or address to see school attendance zones and district boundary lines on our interactive map'
  end

  def set_seo_meta_tags
    set_meta_tags title: meta_title,
                  description: meta_description
  end

end
