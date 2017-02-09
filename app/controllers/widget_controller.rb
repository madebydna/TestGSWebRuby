require 'ostruct'
class WidgetController < ApplicationController

  include GoogleMapConcerns
  include SchoolHelper

  layout :determine_layout
  protect_from_forgery with: :null_session
  after_action :allow_iframe, only: [:map, :gs_map]

  MAX_RESULTS_FOR_MAP = 100
  DEFAULT_RADIUS = 5
  MAX_RADIUS = 60
  MIN_RADIUS = 1

  # this is the form for getting the widget
  def show

  end

  # this is the widget iframe component
  def map
    search_by_type
  end

  # this is the widget iframe component - that will contain all the content
  def gs_map

  end

  # form submission support - ajax - need to create model and db schema for this as well
  def create

  end

  private

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  def search_by_type
    city_from_query ? city_browse : by_location
  end

  def all_digits(str)
    str[/[0-9]+/] == str
  end

  def city_from_query
    @_city_from_query ||= (
      city_from_searchQuery_split_one_segment ||
        city_from_searchQuery_split_two_segment ||
        city_from_params_cityName_state ||
        city_from_searchQuery_zip )
  end

  def city_from_searchQuery_split_one_segment
    sq = params[:searchQuery]
    if sq.present?
      sq_arr =  sq.split(',').map(&:strip)
      # search query has single param like San Francisco
      if sq_arr.present? && sq_arr.length == 1
        city_name = sq_arr[0]
        unless all_digits(city_name)
          city = single_city_or_nil(City.get_city_by_name(city_name))
        end
      end
    end
    city
  end

  def city_from_searchQuery_split_two_segment
    sq = params[:searchQuery]
    if sq.present?
      sq_arr =  sq.split(',').map(&:strip)
      # search query has single param like San Francisco, CA
      if sq_arr.present? && sq_arr.length == 2
        city = search_by_city_state(sq_arr[0], sq_arr[1])
      end
    end
    city
  end

  def city_from_params_cityName_state
    unless usable_lat_lon_values?
      search_by_city_state(params[:cityName], params[:state])
    end
  end

  def city_from_searchQuery_zip
    # try a zip code search using the searchQuery ex. 94607
    sq = params[:searchQuery]
    if sq.present? && !usable_lat_lon_values?
      zip = zip_param(sq)
      if zip.present?
        hash = {:state => zip.state, :name => zip.gs_name}
        city = OpenStruct.new(hash)
      end
    end
    city
  end

  def search_by_single_city_name?
    # search query has single param San Francisco
    if params[:searchQuery].present?
      sq_arr =  params[:searchQuery].split(',')
      sq_arr.present? && sq_arr.length == 1
    end
  end

  def usable_lat_lon_values?
    (/\A[0-9\/.]+\z/.match(params[:lat]).present? && /\A[0-9\/.]+\z/.match(params[:lon]).present?)
  end

  def zip_param(zip_code)
    @_zip_param = (zip_code.present? && zip_code =~ /^\d{5}$/) ? BpZip.find_by_zip(zip_code) : nil
  end

  def search_by_city_state(city_name, state_name)
    state = States.abbreviation(state_name)
    #   if it is a state try to find city in state that is unique
    #   set city variable if successful
    if state.present?
      city = single_city_or_nil(City.get_city_by_name_and_state(city_name, state))
    end
    city
  end

  def single_city_or_nil(city_found)
    city_found.length == 1 ? city_found.first : nil
  end

  def by_location
    if usable_lat_lon_values?

      @state_abbreviation = state_abbreviation
      @by_location = true

      setup_search_results!(Proc.new { |search_options| SchoolSearchService.by_location(search_options) }) do |search_options, params_hash|
        @lat = params_hash['lat']
        @lon = params_hash['lon']
        search_options.merge!({lat: @lat, lon: @lon, radius: radius_param, filters: {:level_code=>levels_from_params}})
        search_options[:state] =  state_abbreviation if @state
        @normalized_address = params_hash['normalizedAddress']
        @search_term = params_hash['locationSearchString']
        city = params_hash['cityName']
      end
    else
      params_hash
      gon.search_failed = 'true'
    end
  end

  def city_browse
    setup_search_results!(Proc.new { |search_options| SchoolSearchService.city_browse(search_options) }) do |search_options|
      search_options.merge!({state: city_from_query.state, city: city_from_query.name, filters: {:level_code=>levels_from_params}})
    end
  end

  def setup_search_results!(search_method)
    @params_hash = params #parse_array_query_string(request.query_string)
    search_options = {number_of_results: MAX_RESULTS_FOR_MAP, offset: 0}
    yield search_options, @params_hash if block_given?
    results = search_method.call(search_options)
    process_results(results, 0) unless results.blank?

  end

  def process_results(results, solr_offset)
    @query_string = '?' + encode_square_brackets(CGI.unescape(@params_hash.to_param))
    @total_results = results[:num_found]
    school_results = results[:results] || []
    relative_offset = solr_offset
    @schools = school_results[relative_offset..(relative_offset+MAX_RESULTS_FOR_MAP-1)]
    @suggested_query = results[:suggestion] if @total_results == 0 #&& search_by_name? #for Did you mean? feature on no results page
    # If the user asked for results 225-250 (absolute), but we actually asked solr for results 25-450 (to support mapping),
    # then the user wants results 200-225 (relative), where 200 is calculated by subtracting 25 (the solr offset) from
    # 225 (the user requested offset)
    # relative_offset = @results_offset - solr_offset
    @schools = school_results[relative_offset..(relative_offset+MAX_RESULTS_FOR_MAP-1)] || []

    if params[:limit]
      if params[:limit].to_i > 0
        @schools = @schools[0..(params[:limit].to_i - 1)] || []
      else
        @schools = []
      end
    end

    (map_start, map_end) = calculate_map_range solr_offset
    @map_schools = school_results[map_start..map_end] || []
    SchoolSearchResultReviewInfoAppender.add_review_info_to_school_search_results!(@map_schools)

    # mark the results that appear in the list so the map can handle them differently
    @schools.each { |school| school.on_page = true } if @schools.present?

    mapping_points_through_gon
    assign_sprite_files_though_gon_widget
  end

  def determine_layout
    application_layout = ['show']
    widget_map_layout = ['map']

    if application_layout.include?(action_name)
      'application'
    elsif widget_map_layout.include?(action_name)
      'widget_map'
    else
      'false'
    end
  end

  def levels_from_params
    @_levels_from_params ||= (
      lc_map = {
          'preschoolFilterChecked'=> :preschool,
          'elementaryFilterChecked'=> :elementary,
          'middleFilterChecked'=> :middle,
          'highFilterChecked'=> :high,
      }
      params.reduce([]) do |a, (k, v)|
        (lc_map.has_key?(k) && v == 'true') ? a << lc_map[k] : a
      end
    )
  end

# duplicate methods in search controller
  def calculate_map_range(solr_offset)
    # solr_offset is used to convert from an absolute range to a relative range.
    # e.g. if user requested 225-250, we want to display on map 150-350. That's the absolute range
    # If we asked solr to give us results 25-425, then the relative range into that resultset is
    # 125-325
    map_start =  solr_offset
    # map_start = 0 if map_start < 0
    # map_start = (@results_offset - solr_offset) if map_start > @results_offset # handles when @page_size > (MAX_RESULTS_FOR_MAP/2)
    map_end = map_start + MAX_RESULTS_FOR_MAP-1
    if map_end > @total_results
      map_end = @total_results-1
      map_start = map_end - MAX_RESULTS_FOR_MAP
      map_start = 0 if map_start < 0
      # map_start = (@results_offset - solr_offset) if map_start > @results_offset
    end
    [map_start, map_end]
  end

  def state_abbreviation
    if @state.is_a?(Hash)
      @state[:short]
    else
      @state
    end
  end

  def params_hash
    @params_hash ||= params #parse_array_query_string(request.query_string)
  end

  # Any time we apply a different filter value than what is in the URL, we should record that here
  # so the view knows how to render the filter form. See search.js::updateFilterState and normalizeInputValue
  # def record_applied_filter_value(filter_name, filter_value)
  #   gon.search_applied_filter_values ||= {}
  #   gon.search_applied_filter_values[filter_name] = filter_value
  # end

  def radius_param
    @radius = params_hash['distance'].presence || DEFAULT_RADIUS
    @radius = Integer(@radius) rescue @radius = DEFAULT_RADIUS
    @radius = MAX_RADIUS if @radius > MAX_RADIUS
    @radius = MIN_RADIUS if @radius < MIN_RADIUS
    @radius
  end

end
