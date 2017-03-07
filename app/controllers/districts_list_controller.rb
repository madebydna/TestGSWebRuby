class DistrictsListController < ApplicationController

  layout 'application'

  before_filter :require_valid_state

  def show
    gon.pageTitle = meta_title
    set_seo_meta_tags
    @dcl = dcl
    cache_time = ENV_GLOBAL['district_city_list_cache_time'] || 0
    expires_in cache_time, public: true
  end

  private

  def state
    params[:state_abbr].upcase
  end

  def dcl
    @_dcl ||= DistrictsCitiesList.new(state)
  end

  def require_valid_state
    unless States.abbreviations.include?(state.downcase)
      render "error/page_not_found", layout: "error", status: 404
    end
  end

  def meta_title
    "All school districts in #{dcl.state_names[:full]}, #{state}"
  end

  def set_seo_meta_tags
    set_meta_tags title: meta_title,
                  canonical: districts_list_url(state_name: dcl.state_names[:routing], state_abbr: state)
  end

end