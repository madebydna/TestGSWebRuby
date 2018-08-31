class DistrictsController < ApplicationController
  include CommunityParams
  include AdvertisingConcerns
  include PageAnalytics
  include CommunityConcerns
  require 'pry'

  layout 'application'
  # before_action :set_city_state
  # before_action :require_district
  # before_action :set_hub
  # before_action :add_collection_id_to_gtm_data_layer
  # before_action :set_login_redirect
  # before_action :redirect_to_canonical_url
  before_filter :redirect_unless_valid_district

  def show
    # gon.pagename = 'DistrictHome'
    # @district = district
    # @ad_page_name = :District_Home # TODO verify name to use

    # @nearby_districts = @district.nearby_districts
    # @canonical_url = city_district_url(district_params_from_district(@district))

    # @top_schools = top_schools(@district, 4)
    # @params_hash = parse_array_query_string(request.query_string)
    # @show_ads = hub_show_ads? && PropertyConfig.advertising_enabled?

    # @breadcrumbs = district_home_breadcrumbs
    # write_meta_tags
    # ad_setTargeting_through_gon
    # data_layer_through_gon
    # prepare_map
    # render 'districts/district_home'
    set_district_meta_tags
    @district = DistrictCache.cached_results_for([district_record], ['district_schools_summary', 'district_characteristics']).decorate_districts([district_record]).first
    # @decorated_districts = decorated_districts
    @schools = serialized_schools
    @breadcrumbs = breadcrumbs
    @locality = locality
    # # @districts = districts_by_city
    # @school_levels = school_levels
    # @districts = district_content
  end

  private
  def set_district_meta_tags
    district_params_hash = district_params(state, city, district)
    set_meta_tags(alternate: {en: url_for(lang: nil), es: url_for(lang: :es)},
                  title: districts_title,
                  description: districts_description,
                  canonical: city_district_url(state: district_params_hash[:state], city: district_params_hash[:city], district: district_params_hash[:district]))
  end

  def districts_title
    additional_district_text = state.downcase == 'dc' ? ', DC' : ''
    "#{district_record.name.gs_capitalize_words}#{additional_district_text} School District in #{district_record.city}, #{district_record.state}."
  end

  def districts_description
    "Information to help parents choose the right public school for their children in the "+
      "#{district_record.name}."
  end

  def districts_state_text
    state.downcase == 'dc' ? '' : "#{district_record.name.gs_capitalize_words} #{state_name.gs_capitalize_words} "
  end

  # AdvertisingConcerns
  def ad_targeting_props
    {
      page_name: "GS:District:Home",
      template: "search",
    }.tap do |hash|
      # these intentionally capitalized to match property names that have
      # existed for a long time. Not sure if it matters
      hash[:City] = city.gs_capitalize_words if city
      hash[:State] = state if state
      hash[:District] = district if district
      hash[:level] = level_codes.map { |s| s[0] } if level_codes.present?
      hash[:county] = county_record.name if county_record
    end
  end

  # PageAnalytics
  def page_analytics_data
    {}.tap do |hash|
      # placeholder
    end
  end

  def district_cache_school_levels
    # @_district_cache_school_levels ||= begin
    #   cc= 
  end

  def locality
    @_locality ||= begin
      Hash.new.tap do |cp|
        cp[:city] = district_record.city
        cp[:stateLong] = state_name.gs_capitalize_words
        cp[:stateShort] = state.upcase
        cp[:county] = county_record&.name
        # cp[:districtBrowseUrl] = search_district_browse_path(district_params(state, city, district))
      end
    end
  end

  def breadcrumbs
    @_district_breadcrumbs ||= [
      {
        text: StructuredMarkup.state_breadcrumb_text(state),
        url: state_url(state_params(state))
      },
      {
        text: StructuredMarkup.city_breadcrumb_text(state: state, city: city),
        url: city_url(city_params(state, city))
      },
      {
        text: district_record.name&.gs_capitalize_words,
        url: ""
      }
    ]
  end

  def decorated_district
    # @_decorated_district
  end

  def redirect_unless_valid_district
    redirect_to(city_path(state: state_name, city: city&.downcase), status: 301) unless district_record
  end

end
