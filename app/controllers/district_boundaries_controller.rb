class DistrictBoundariesController < ApplicationController
  layout "application"

  def show
    set_seo_meta_tags
  end

  def meta_title
    'What School District Are You In? District Boundary Map | GreatSchools'
  end

  def meta_description
    'See what school district you are in by providing your zip code or address in our interactive map.'
  end

  def set_seo_meta_tags
    set_meta_tags title: meta_title,
                  description: meta_description
  end

end
