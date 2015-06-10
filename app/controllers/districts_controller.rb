class DistrictsController < ApplicationController
  include SeoHelper
  include MetaTagsHelper
  include HubConcerns
  include GoogleMapConcerns

  before_action :set_city_state
  before_action :require_district
  before_action :set_hub
  before_action :set_login_redirect
  before_action :write_meta_tags
  before_action :redirect_to_canonical_url

  def show
    gon.pagename = 'DistrictHome'
    @ad_page_name = :District_Home # TODO verify name to use

    @nearby_districts = @district.nearby_districts
    @canonical_url = city_district_url(district_params_from_district(@district))

    @top_schools = top_schools(@district, 4)
    @params_hash = parse_array_query_string(request.query_string)
    @show_ads = hub_show_ads? && PropertyConfig.advertising_enabled?
    ad_setTargeting_through_gon
    data_layer_through_gon
    prepare_map
    set_omniture_data
    render 'districts/district_home'
  end

  private

  def require_district
    @district = District.find_by_state_and_name(state_param, district_param)
    return redirect_to city_url if @district.nil?
  end

  def redirect_to_canonical_url
    # Add a tailing slash to the request path, only if one doesn't already exist.
    # Requests made by rspec sometimes contain a trailing slash
    unless canonical_path == with_trailing_slash(request.path)
      redirect_to add_query_params_to_url(
        canonical_path,
        true,
        request.query_parameters
      )
    end
  end

  def canonical_path
    city_district_path(district_params_from_district(@district))
  end

  def set_omniture_data
    gon.omniture_sprops = {}
    gon.omniture_pagename = "GS:District:Home"
    gon.omniture_hier1 = "District,District Home,#{@district.name}"
    gon.omniture_sprops['locale'] = @city
    gon.omniture_channel = @state[:short].try(:upcase) if @state
  end

  def top_schools(district, count = 10)
    district.schools_by_rating_desc.take(count)
  end

  def prepare_map
    @map_schools = @district.schools_by_rating_desc
    mapping_points_through_gon_from_db(@map_schools)
    assign_sprite_files_though_gon
  end

  def page_view_metadata
    @page_view_metadata ||= (
    page_view_metadata = {}
    page_view_metadata['compfilter'] = (1 + rand(4)).to_s # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
    page_view_metadata['env']        = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
    page_view_metadata['State']      = @state[:short].upcase # abbreviation
    page_view_metadata['editorial']  = 'FindaSchoo'
    page_view_metadata['template']   = "ros" # use this for page name - configured_page_name

    page_view_metadata
    )

  end

  def ad_setTargeting_through_gon
    @ad_definition = Advertising.new
    if show_ads?
      page_view_metadata.each do |key, value|
        ad_targeting_gon_hash[key] = value
      end
    end
  end

  def data_layer_through_gon
    data_layer_gon_hash.merge!(page_view_metadata)
  end

end
