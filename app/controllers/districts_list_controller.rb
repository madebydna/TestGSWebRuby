class DistrictsListController < ApplicationController

  layout 'application'

  before_filter :require_valid_state

  before_action :set_city_state, only: [:suggest_district_by_name]

  def show
    gon.pageTitle = meta_title
    set_seo_meta_tags
    @dcl = dcl
  end

  def suggest_district_by_name
    set_city_state

    state_abbr = state if state.present?
    response_objects = SearchSuggestDistrict.new.search(count: 10, state: state_abbr, query: params[:query])

    set_cache_headers_for_suggest
    render json:response_objects
  end

  def set_cache_headers_for_suggest
    cache_time = ENV_GLOBAL['district_city_list_cache_time'] || 0
    expires_in cache_time, public: true
  end


  private

  def state
    params[:state_name]
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
                  canonical: "http://www.greatschools.org/schools/districts/#{dcl.state_names[:routing]}/#{state}/"
  end

end