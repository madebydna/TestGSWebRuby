require 'ostruct'
class WidgetController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams
  include SearchControllerConcerns
  include UrlHelper


  layout :determine_layout
  protect_from_forgery with: :null_session
  after_action :allow_iframe, only: [:map, :gs_map, :map_and_links]

  # this is the form for getting the widget
  def show
    set_meta_tags(
      title: 'GreatSchools School Finder Widget | GreatSchools',
      canonical: widget_url
    )
    data_layer_gon_hash.merge!({
      'page_name'   => 'GS:WidgetForm',
      'template'    => 'widget_form'
    })
  end

  # this is the widget iframe component
  def map
    @params_hash ||= params
    @width = width
    @height = height
    @search_params = params.slice(:lat, :lon)
    @search_params[:locationLabel] = params[:normalizedAddress]
    @search_params[:gradeLevels] = level_codes if level_codes.present?
    @static_map_url = static_map_url
    @serialized_schools = serialized_schools
    gon.search_failed = serialized_schools.empty?
    @rating_level = RATING_TO_PERFORMANCE_LEVEL
    @school_types_map = SCHOOL_TYPES_MAP
  end

  RATING_COLORS = {
      10 => '0x439325',
      9 => '0x559F23',
      8 => '0x6BA721',
      7 => '0x86B31F',
      6 => '0xA3BE1E',
      5 => '0xBDC01D',
      4 => '0xD2B81A',
      3 => '0xDCA219',
      2 => '0xE78817',
      1 => '0xF26B16',
  };

  RATING_TO_PERFORMANCE_LEVEL = {
      0 => 'Currently Unrated',
      1 => 'Below Average',
      2 => 'Below Average',
      3 => 'Below Average',
      4 => 'Average',
      5 => 'Average',
      6 => 'Average',
      7 => 'Average',
      8 => 'Above Average',
      9 => 'Above Average',
      10 => 'Above Average'
  };

  SCHOOL_TYPES_MAP = {
      'charter' => 'Public charter',
      'public' => 'Public district',
      'private' => 'Private'
  }

  STATIC_MAP_WIDTH_CORRECTION = 15
  STATIC_MAP_HEIGHT_CORRECTION = 175
  STATIC_MAP_CUTOFF = 640

  def static_map_url
    marker_styles = Hash.new { |h,k| h[k] = [] }
    serialized_schools.each do |s|
      rating = s[:rating].to_i
      style_str = 'color:gray|'
      if rating > 0
        style_str = "color:#{RATING_COLORS[rating]}|"
      end
      marker_styles[style_str] << "#{s[:lat]},#{s[:lon]}"
    end
    google_apis_path = GoogleSignedImages::STATIC_MAP_URL
    address = params[:normalizedAddress] ? params[:normalizedAddress].gsub(/\s+/,'+').gsub(/'/,'') : ''
    scale = 1
    width_static_map = width-STATIC_MAP_WIDTH_CORRECTION
    height_static_map = height-STATIC_MAP_HEIGHT_CORRECTION
    if width_static_map > STATIC_MAP_CUTOFF
      scale = 2
      width_static_map = (width_static_map/2).floor
      height_static_map = (height_static_map/2).floor
    end
    url = "#{google_apis_path}?size=#{width_static_map}x#{height_static_map}&scale=#{scale}&center=#{address}&zoom=13&markers=color:blue|#{address}"
    marker_styles.each do |style, markers|
      url += "&markers=#{style}#{markers.join('|')}"
    end
    url += "&sensor=false"
    GoogleSignedImages.sign_url(url, ENV_GLOBAL['GOOGLE_MAPS_WIDGET_API_KEY'])
  end

  def map_and_links
    map
    render 'map_and_links'
  end

  # this is the widget iframe component - that will contain all the content
  def gs_map

  end

  # form submission support - ajax - need to create model and db schema for this as well
  def create

  end

  def test
    render 'test', layout: 'admin'
  end

  private

  def width
    (params[:width].presence || 300)&.to_i
  end

  def height
    (params[:height].presence || 340)&.to_i
  end

  # SearchRequestParams
  def default_limit
    50
  end

  # SearchRequestParams
  def level_codes
    @_level_codes ||= (
      lc_map = {
          'preschoolFilterChecked'=> :p,
          'elementaryFilterChecked'=> :e,
          'middleFilterChecked'=> :m,
          'highFilterChecked'=> :h,
      }
      params.reduce([]) do |a, (k, v)|
        (lc_map.has_key?(k) && v == 'true') ? a << lc_map[k] : a
      end
    )
  end

  # SearchRequestParams
  def default_extras
    %w(summary_rating distance assigned enrollment students_per_teacher review_summary)
  end

  # SearchRequestParams
  def max_radius
    60
  end

  # SearchControllerConcerns
  def solr_query
    query_type = Search::SolrSchoolQuery
    query_type.new(
      # city: city,
      state: state,
      location_label: location_label_param,
      level_codes: level_codes,
      entity_types: entity_types,
      lat: lat,
      lon: lon,
      radius: radius,
      q: q,
      offset: offset,
      limit: limit,
      sort_name: 'rating'
    )
  end

  # SearchControllerConcerns
  def serialized_schools
    # Using a plain rubo object to convert domain object to json
    # decided not to use jbuilder. Dont feel like it adds benefit and
    # results in less flexible/resuable code. Could use
    # active_model_serializers (included with rails 5) but it's yet another
    # gem...
    @_serialized_schools ||= schools.map do |school|
      Api::SchoolSerializer.new(school).to_hash.tap do |s|
        s.except([] - extras)
      end
    end
  end

  # SearchRequestParams
  def q
    '' #params[:searchQuery] || ''
  end

  # SearchRequestParams
  def city
    return params[:cityName] if params[:cityName].present?
    city_from_q = q.split(',').first&.strip
    return city_from_q unless all_digits?(city_from_q)
  end

  # SearchRequestParams
  def state
    return super if super.present?
    phrases = q.split(',')
    if phrases.length == 2
      return States.abbreviation(phrases.last)
    end
  end

  # SearchRequestParams
  def city_record
    @_city_record ||= (
      if city && state
        record ||= City.get_city_by_name_and_state(city, state)
      end
      record ||= City.get_city_by_name(city)
      if zip_record.present?
        record ||= OpenStruct.new(state: zip_record.state, name: zip_record.gs_name)
      end
      record
    )
  end

  def zip_param
    q
  end

  def zip_record
    if defined?(@_zip_record)
      return @_zip_record
    end
    @_zip_record = (zip_param.present? && zip_param =~ /^\d{5}$/) ? BpZip.find_by_zip(q) : nil
  end

  def transform_for_widget(school)
    school_types_map = {
      'charter' => 'Public charter',
      'public' => 'Public district',
      'private' => 'Private'
    }
    school.merge!({
      zillowUrl: zillow_url(school[:state], school.dig(:address, :zip), 'widget_map'),
      profileUrl: school.dig(:links,:profile),
      reviewUrl: school.dig(:links,:reviews),
      communityRatingStars: school.delete(:parentRating),
      lng: school.delete(:lon),
      city: school.dig(:address, :city),
      gradeRange: school.delete(:gradeLevels),
      street: school.dig(:address, :street1),
      zipcode: school.dig(:address, :zip),
      schoolType: school_types_map[school[:schoolType].downcase]&.gs_capitalize_first,
      state: school[:state].downcase,
      gsRating: school.delete(:rating),
      preschool: school[:levelCode] == 'p',
      on_page: true
    })
    school.delete(:links)
    school.delete(:address)
    school
  end

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def all_digits?(str)
    str && str[/[0-9]+/] == str
  end

  def usable_lat_lon_values?
    (match_string_lat_lon(params[:lat]).present? && match_string_lat_lon(params[:lon]).present?)
  end

  #TODO should only match to a single dot - added optional negative to the front.
  def match_string_lat_lon(str)
    /\A-?[0-9\/.]+\z/.match(str)
  end

  def determine_layout
    application_layout = ['show']
    widget_map_layout = ['map','map_and_links']

    if application_layout.include?(action_name)
      'application'
    elsif widget_map_layout.include?(action_name)
      'widget_map'
    else
      'false'
    end
  end

end
