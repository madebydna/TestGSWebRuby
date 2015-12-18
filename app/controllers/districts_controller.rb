class DistrictsController < ApplicationController
  include SeoHelper
  include DistrictsMetaTagsConcerns
  include HubConcerns
  include GoogleMapConcerns

  before_action :set_city_state
  before_action :require_district
  before_action :set_hub
  before_action :add_collection_id_to_gtm_data_layer
  before_action :set_login_redirect
  before_action :redirect_to_canonical_url

  def show
    gon.pagename = 'DistrictHome'
    @district = district
    @ad_page_name = :District_Home # TODO verify name to use

    @nearby_districts = @district.nearby_districts
    @canonical_url = city_district_url(district_params_from_district(@district))

    @top_schools = top_schools(@district, 4)
    @params_hash = parse_array_query_string(request.query_string)
    @show_ads = hub_show_ads? && PropertyConfig.advertising_enabled?

    @breadcrumbs = district_home_breadcrumbs
    write_meta_tags
    ad_setTargeting_through_gon
    data_layer_through_gon
    prepare_map
    render 'districts/district_home'
  end

  private

  def write_meta_tags
    method_base = "#{controller_name}_#{action_name}"
    title_method = "#{method_base}_title".to_sym
    description_method = "#{method_base}_description".to_sym
    keywords_method = "#{method_base}_keywords".to_sym
    set_meta_tags title: send(title_method), description: send(description_method), keywords: send(keywords_method)
  end

  def district
    return @_district if defined?(@_district)
    @_district ||= (
      District.find_by_state_and_name(state_param_safe, district_param)
    )
  end

  def district_home_breadcrumbs
    if ( @state.present? &&  @city.present?)
    breadcrumbs = {
        @state[:long].titleize => state_path(params[:state]),
        @city.titleize => city_path(params[:state], params[:city])
    }
    end
  end

  def require_district
    return redirect_to city_url if district.nil?
  end

  def district_param
    return if params[:district].nil?
    gs_legacy_url_decode(params[:district])
  end

  def redirect_to_canonical_url
    #  this prevents an endless redirect loop for the district pages
    canonical_path = remove_query_params_from_url( self.city_district_path(district_params_from_district(district)), [:lang] )

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
    page_view_metadata['page_name']    = 'GS:District:Home'
    page_view_metadata['compfilter'] = (1 + rand(4)).to_s # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
    page_view_metadata['env']        = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
    page_view_metadata['State']      = @state[:short].upcase # abbreviation
    page_view_metadata['City']       = @district.city
    page_view_metadata['county']     = @district.county if @district.county
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
