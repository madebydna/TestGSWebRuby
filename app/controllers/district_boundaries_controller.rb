class DistrictBoundariesController < ApplicationController
  include PageAnalytics
  
  layout "application"

  def show
    set_seo_meta_tags
    set_page_analytics_data
  end

  def meta_title
    t('district_boundaries.controller.meta_title')
  end

  def meta_description
    t('district_boundaries.controller.meta_description')
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
                  canonical: district_boundary_url,
                  alternate: {en: url_for(lang: nil), es: url_for(lang: :es)}
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
