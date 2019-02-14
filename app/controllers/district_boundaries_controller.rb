class DistrictBoundariesController < ApplicationController
  include PageAnalytics
  
  layout "application"

  def show
    set_seo_meta_tags
    set_page_analytics_data
  end

  def meta_title
    'What School District Are You In? District Boundary Map | GreatSchools'
  end

  def meta_description
    'See what school district you are in by providing your zip code or address in our interactive map.'
  end

  def open_graph
    {
        title: 'GreatSchools: See what school district you are in or moving to using our interactive map.',
        type: 'website',
        url: district_boundary_url,
        site_name: 'See What School District You Are In'
    }
  end

  def set_seo_meta_tags
    set_meta_tags title: meta_title,
                  description: meta_description,
                  og: open_graph,
                  canonical: district_boundary_url
  end

  def state
    params[:state]
  end

  def school_id
    params[:schoolId]
  end

  # PageAnalytics
  def page_analytics_data
    {}.tap do |hash|
      hash[PageAnalytics::PAGE_NAME] = 'GS:DistrictBoundaryTool'
      hash[PageAnalytics::STATE] = state
      hash[PageAnalytics::SCHOOL_ID] = school_id
    end
  end
end
