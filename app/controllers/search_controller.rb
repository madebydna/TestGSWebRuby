# frozen_string_literal: true

class SearchController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams
  include AdvertisingConcerns
  include PageAnalytics
  include SearchControllerConcerns
  include SearchTableConcerns

  layout 'application'
  before_filter :redirect_unless_valid_search_criteria # we need at least a 'q' param or state and city/district

  def search
    gon.search = {
      schools: serialized_schools,
    }.tap do |props|
      props['state'] = state
      if lat && lon
        props['lat'] = lat
        props['lon'] = lon
      end
      props.merge!(Api::CitySerializer.new(city_record).to_hash) if city_record
      props[:district] = district_record.name if district_record
      props.merge!(Api::PaginationSummarySerializer.new(page_of_results).to_hash)
      props.merge!(Api::PaginationSerializer.new(page_of_results).to_hash)
      props[:breadcrumbs] = should_include_breadcrumbs? ? search_breadcrumbs : []
      props[:searchTableViewHeaders] = {
          'Overview' => overview_header_hash,
          'Equity' => equity_header_hash(schools),
          'Academic' => academic_header_hash
      }
    end
    gon.search['facetFields'] = populated_facet_fields
    set_meta_tags(Search::MetaTags.from_controller(self).meta_tag_hash)
    set_ad_targeting_props
    set_page_analytics_data
    response.status = 404 if serialized_schools.empty?
  end

  ## ported over to support legacy search

  def suggest_school_by_name
    set_city_state
    response_objects = SearchSuggestSchool.new.search(count: 20, state: state, query: params[:query])
    set_cache_headers_for_legacy_suggest
    render json:response_objects
  end

  def suggest_city_by_name
    set_city_state
    response_objects = SearchSuggestCity.new.search(count: 10, state: state, query: params[:query])
    set_cache_headers_for_legacy_suggest
    render json:response_objects
  end

  def suggest_district_by_name
    set_city_state
    response_objects = SearchSuggestDistrict.new.search(count: 10, state: state, query: params[:query])
    set_cache_headers_for_legacy_suggest
    render json:response_objects
  end

  ## end legacy search code

  private

  def set_cache_headers_for_legacy_suggest
    cache_time = ENV_GLOBAL['search_suggest_cache_time'] || 0
    expires_in cache_time, public: true
  end

  def should_include_breadcrumbs?
    city_browse? || district_browse?
  end

  def search_breadcrumbs
    district_browse? ? district_breadcrumbs : city_breadcrumbs
  end

  def city_breadcrumbs
    @_city_breadcrumbs ||= [
      {
        text: StructuredMarkup.state_breadcrumb_text(state),
        url: state_url(state_params(state))
      },
      {
        text: StructuredMarkup.city_breadcrumb_text(state: state, city: city),
        url: city_url(city_params(state, city))
      }
    ]
  end

  def district_breadcrumbs
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
        text: district&.gs_capitalize_words,
        url: district_url(district_params(state_name, city,  district))
      }
    ]
  end

  # StructuredMarkup
  def prepare_json_ld
    if should_include_breadcrumbs?
      search_breadcrumbs.each { |bc| add_json_ld_breadcrumb(bc) }
    end
  end

  # AdvertisingConcerns
  def ad_targeting_props
    {
      page_name: "GS:SchoolS",
      template: "search",
    }.tap do |hash|
      hash[:district_id] = district_id if district_id
      hash[:school_id] = school_id if school_id
      # these intentionally capitalized to match property names that have
      # existed for a long time. Not sure if it matters
      hash[:City] = city.gs_capitalize_words if city
      hash[:State] = state if state
      hash[:level] = level_codes.map { |s| s[0] } if level_codes.present?
      hash[:type] = entity_types.map(&:capitalize) if entity_types.present?
      hash[:county] = county_object&.name if county_object
      # hash[:zipcode]
    end
  end

  # PageAnalytics
  def page_analytics_data
    {}.tap do |hash|
      hash[PageAnalytics::SEARCH_TERM] = q if q
      hash[PageAnalytics::SEARCH_TYPE] = search_type
      hash[PageAnalytics::SEARCH_HAS_RESULTS] = page_of_results.any?
      hash[PageAnalytics::PAGE_NAME] = 'GS:SchoolSearchResults'
    end
  end

  # Paginatable
  def default_limit
    25
  end

  def redirect_unless_valid_search_criteria
    if q.present? || (lat.present? && lon.present?)
      return
    elsif state && district
      unless district_record
        if city_record
          redirect_to city_path(city: city_param, state: state_param)
        else
          redirect_to(state_path(States.state_path(state)))
        end
      end
      unless city_record
        # If the city name in the district record doesn't match one in city table, you'll get an infinite redirect.
        # This checks that a record can be found in the city table before trying to use it for the redirect.
        if district_record.city_record
          redirect_to search_district_browse_path(States.state_path(state), city: gs_legacy_url_encode(district_record.city), district_name: district_param)
        else
          redirect_to(state_path(States.state_path(state)))
        end
      end
    elsif state && city
      redirect_to(state_path(States.state_path(state))) unless city_record
    elsif state
      redirect_to(state_path(States.state_path(state)))
    else
      redirect_to home_path
    end

  end

  # extra items returned even if not requested (besides school fields etc)
  # SearchRequestParams
  def default_extras
    %w(summary_rating distance assigned enrollment students_per_teacher review_summary saved_schools all_ratings)
  end

  # extras requiring specific ask, otherwise removed from response
  # SearchRequestParams
  def not_default_extras
    %w(geometry)
  end


end