class CitiesListController < ApplicationController

  layout 'application'

  before_filter :require_valid_state, :except => :old_homepage

  def show
    gon.pageTitle = meta_title
    set_seo_meta_tags
    @dcl = dcl
    cache_time = ENV_GLOBAL['district_city_list_cache_time'] || 0
    expires_in cache_time, public: true
  end

  def old_homepage
    state_name = States.state_path(params[:state_abbr])
    city_name = params[:city].downcase.gsub('_', '-').gsub(/\A-+|-+\Z/, '')

    return redirect_to :root if state_name.nil?

    target_url = city_path(:state => state_name, :city => city_name)
    query_params = request.query_parameters.to_query
    query_params = "?#{query_params}" unless query_params.empty?

    redirect_to "#{target_url}#{query_params}", :status => 301
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
    "#{dcl.state_names[:full]} School information by City: Popular Cities"
  end

  def set_seo_meta_tags
    set_meta_tags title: meta_title,
                  canonical: cities_list_url(state_name: dcl.state_names[:routing], state_abbr: state)
  end

end
