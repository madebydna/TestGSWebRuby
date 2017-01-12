class WidgetController < ApplicationController

  include GoogleMapConcerns
  include SchoolHelper

  layout :determine_layout

  MAX_RESULTS_FOR_MAP = 100
  DEFAULT_RADIUS = 5
  MAX_RADIUS = 60
  MIN_RADIUS = 1

  # this is the form for getting the widget
  def show

  end

  # this is the widget iframe component
  def map
    by_location
  end

  # this is the widget iframe component - that will contain all the content
  def gs_map

  end

  # form submission support - ajax - need to create model and db schema for this as well
  def create

  end


  private

  def by_location
    @state_abbreviation = state_abbreviation
    city = nil
    @by_location = true
    setup_search_results!(Proc.new { |search_options| SchoolSearchService.by_location(search_options) }) do |search_options, params_hash|
      @lat = params_hash['lat']
      @lon = params_hash['lon']
      search_options.merge!({lat: @lat, lon: @lon, radius: radius_param})
      search_options[:state] =  state_abbreviation if @state
      @normalized_address = params_hash['normalizedAddress']
      @search_term = params_hash['locationSearchString']
      city = params_hash['city']
    end

    # @nearby_cities = SearchNearbyCities.new.search(lat:@lat, lon:@lon, count:NUM_NEARBY_CITIES, state: state_abbreviation)

    # set_meta_tags search_by_location_meta_tag_hash
    # setup_search_gon_variables
  end


  def setup_search_results!(search_method)
    @params_hash = parse_array_query_string(request.query_string)

    search_options = {number_of_results: MAX_RESULTS_FOR_MAP, offset: 0}

    yield search_options, @params_hash if block_given?

    results = search_method.call(search_options)
    process_results(results, 0) unless results.empty?

  end

  def process_results(results, solr_offset)
    @query_string = '?' + encode_square_brackets(CGI.unescape(@params_hash.to_param))
    @total_results = results[:num_found]

    school_results = results[:results] || []
    relative_offset = solr_offset


      @schools = school_results[relative_offset..(relative_offset+MAX_RESULTS_FOR_MAP-1)]
      # setup_fit_scores(@schools, @params_hash) if filtering_search?

    @suggested_query = results[:suggestion] if @total_results == 0 && search_by_name? #for Did you mean? feature on no results page
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

    # require 'pry'
    # binding.pry
    mapping_points_through_gon
    assign_sprite_files_though_gon

    # set_pagination_instance_variables(@total_results) # @max_number_of_pages @window_size @pagination
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

# duplicate methods in search controller
  def calculate_map_range(solr_offset)
    # solr_offset is used to convert from an absolute range to a relative range.
    # e.g. if user requested 225-250, we want to display on map 150-350. That's the absolute range
    # If we asked solr to give us results 25-425, then the relative range into that resultset is
    # 125-325
    map_start =  0
    # map_start = 0 if map_start < 0
    # map_start = (@results_offset - solr_offset) if map_start > @results_offset # handles when @page_size > (MAX_RESULTS_FOR_MAP/2)
    map_end = map_start + MAX_RESULTS_FOR_MAP-1
    if map_end > @total_results
      map_end = @total_results-1
      map_start = map_end - MAX_RESULTS_FOR_MAP
      map_start = 0 if map_start < 0
      map_start = (@results_offset - solr_offset) if map_start > @results_offset
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
    @params_hash ||= parse_array_query_string(request.query_string)
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
    # record_applied_filter_value('distance', @radius) unless "#{@radius}" == params_hash['distance']
    @radius
  end

end
