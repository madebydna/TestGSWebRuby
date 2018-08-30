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
    set_search_meta_tags
    set_ad_targeting_props
    set_page_analytics_data
    set_meta_tags(alternate: {
      en: url_for(params_for_rel_alternate.merge(lang: nil)),
      es: url_for(params_for_rel_alternate.merge(lang: :es))
    })
    response.status = 404 if serialized_schools.empty?
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
    %w(summary_rating distance assigned enrollment students_per_teacher review_summary)
  end

  # extras requiring specific ask, otherwise removed from response
  # SearchRequestParams
  def not_default_extras
    %w(geometry)
  end

  # Begin meta-tag code
  def prev_page
    @_prev_page ||= prev_page_url(page_of_results)
  end

  def next_page
    @_next_page ||= next_page_url(page_of_results)
  end

  def set_search_meta_tags
    set_meta_tags(robots: 'noindex, nofollow') unless is_browse_url? && page_of_results.present?
    if %i[zip_code city_browse district_browse].include?(search_type)
      complete_tags = send("#{search_type}_meta_tag_hash".to_sym).merge({prev: prev_page, next: next_page})
      send(:set_meta_tags, complete_tags)
    end
  end

  def city_browse_meta_tag_hash
    if %w(il pa).include?(state)
      meta_description = "#{city_record.name}, #{city_record.state} school districts, public, private and charter school listings" \
          " and rankings for #{city_record.name}, #{city_record.state}. Find your school district information from Greatschools.org"
    else
      meta_description = "View and map all #{city_record.name}, #{city_record.state} schools. Plus, compare or save schools"
    end

    {
      title: "#{city_browse_title} | GreatSchools",
      description: meta_description,
      canonical: search_city_browse_url(
        params_for_canonical.merge(
          city: gs_legacy_url_encode(city),
          state: gs_legacy_url_encode(States.state_name(state))
        )
      )
    }
  end

  def district_browse_meta_tag_hash
    {
      title: "#{district_browse_title} | GreatSchools",
      description: "Ratings and parent reviews for all elementary, middle and high schools in the #{district_record.name}, #{city_record.state}",
      canonical: search_district_browse_url(
        params_for_canonical.merge(
          district_name: gs_legacy_url_encode(district),
          city: gs_legacy_url_encode(city),
          state: gs_legacy_url_encode(States.state_name(state))
        )
      )
    }
  end

  def zip_code_meta_tag_hash
    {
      title: "#{zip_code_search_title} | GreatSchools",
      description: "Ratings and parent reviews for all elementary, middle and high schools in #{zip_code}, #{state.upcase}"
    }
  end

  def city_browse_title
    city_type_level_code_text = "#{city_record.name} #{entity_type_long}#{level_code_long}#{schools_or_preschools}"
    "#{city_type_level_code_text}#{pagination_text} - #{city_record.name}, #{city_record.state}"
  end

  def district_browse_title
    "#{entity_type_long}#{level_code_long}#{schools_or_preschools} in #{district_record.name}#{pagination_text} - #{city_record.name}, #{city_record.state}"
  end

  def zip_code_search_title
    "#{entity_type_long}#{level_code_long}#{schools_or_preschools} in #{zip_code}#{pagination_text} - #{state.upcase}"
  end

  def pagination_text
    return if offset > page_of_results.total
    ", #{(offset + 1).to_s}-#{(offset + 1 + page_of_results.length).to_s}"
  end

  def entity_type_long
    {
      'charter' => 'Public Charter ',
      'public' => 'Public ',
      'private' => 'Private '
    }[entity_type]
  end

  def level_code_long
    {
      'e' => 'Elementary ',
      'm' => 'Middle ',
      'h' => 'High ',
      'p' => nil
    }[level_code]
  end

  def schools_or_preschools
    school_preschool_map = Hash.new('Schools').merge('p' => 'Preschools')
    school_preschool_map[level_code]
  end

  def params_for_canonical
    {
      grade_level_param_name => level_code,
      page_param_name => given_page,
      school_type_param_name => entity_type
    }.compact
  end

  def params_for_rel_alternate
    {
      grade_level_param_name => level_codes,
      page_param_name => given_page,
      school_type_param_name => entity_types,
    }.compact
  end

end