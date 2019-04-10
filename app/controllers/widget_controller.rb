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
    gon.map_points = serialized_schools.map { |s| transform_for_widget(s) }
    gon.sprite_files = {}
    gon.sprite_files['imageUrlPrivateSchools'] = view_context.image_path('icons/google_map_pins/private_school_markers.png')
    gon.sprite_files['imageUrlPublicSchools'] = view_context.image_path('icons/google_map_pins/public_school_markers.png')
    gon.search_failed = serialized_schools.empty?
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
    100
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
      # state: state,
      location_label: location_label_param,
      level_codes: level_codes,
      entity_types: entity_types,
      lat: lat,
      lon: lon,
      radius: radius,
      q: q,
      offset: offset,
      limit: limit,
      with_rating: true,
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
    params[:searchQuery] || ''
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
