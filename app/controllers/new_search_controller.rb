# frozen_string_literal: true

class NewSearchController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams
  include AdvertisingConcerns
  include PageAnalytics
  include SearchControllerConcerns

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
    end

    prev_page = prev_page_url(page_of_results)
    next_page = next_page_url(page_of_results)
    set_meta_tags(prev: prev_page) if prev_page
    set_meta_tags(next: next_page) if next_page
    set_meta_tags(robots: 'noindex, nofollow') unless is_browse_url? && page_of_results.present?
    set_ad_targeting_props
    set_page_analytics_data
    set_meta_tags(alternate: {
      en: url_for(params.merge(lang: nil)),
      es: url_for(params.merge(lang: :es))
    })
  end

  private

  def should_include_breadcrumbs?
    city_browse? || district_browse?
  end

  def search_breadcrumbs
    @_search_breadcrumbs ||= [
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
          redirect_to city_path(city: city_param, state: state_param) && return
        else
          redirect_to(state_path(States.state_path(state))) && return
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
    %w(summary_rating distance assigned enrollment students_per_teacher review_summary)
  end

  # extras requiring specific ask, otherwise removed from response
  # SearchRequestParams
  def not_default_extras
    %w(geometry)
  end

end