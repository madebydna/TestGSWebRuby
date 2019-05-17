# frozen_string_literal: true

# a.k.a. CSA
class CollegeSuccessAwardController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams
  include AdvertisingConcerns
  include PageAnalytics
  include SearchControllerConcerns
  include SearchTableConcerns

  layout 'application'
  before_filter :redirect_unless_valid_search_criteria # we need at least a 'q' param or state and city/district

  def search
    redirect_to state_url(state_params(state)) unless serialized_schools.present?
    gon.search = {
      schools: serialized_schools,
    }.tap do |props|
      props['state'] = state
      if lat && lon
        props['lat'] = lat
        props['lon'] = lon
      end
      props.merge!(Api::PaginationSummarySerializer.new(page_of_results).to_hash)
      props.merge!(Api::PaginationSerializer.new(page_of_results).to_hash)
      props.merge!(Api::SortOptionSerializer.new(page_of_results.sortable_fields - ['csa_badge']).to_hash)
      props.merge!({
        tableViewOptions: (csa_available_years).map do |year|
          {
            key: year,
            label: t('csa_year_winners', scope: 'lib.college_success_award', year: year)
          }
        end
      })
      props[:breadcrumbs] = breadcrumbs
      props[:searchTableViewHeaders] =
        csa_available_years.each_with_object({}) do | year, hash |
          hash[year] = college_success_award_header_arr
        end
      props[:view] = view || default_view
    end
    gon.search['facetFields'] = populated_facet_fields
    gon.search['csaYears'] = csa_available_years
    set_meta_tags(choose_meta_tag_implementation.new(self).meta_tag_hash)
    set_page_analytics_data
    # set_ad_targeting_props
  end

  # SearchRequestParams
  def default_view
    'table'
  end

  def csa_available_years
    @csa_years ||= csa_available_years_query.response.facet_fields['csa_badge'].each_slice(2).select {|x| x[1] > 0}.map(&:first).map(&:to_i).sort.reverse
  end

  def csa_available_years_query
    Search::CSAQuery.new(
      state: state,
      csa_years: (2018..2030).to_a,
      offset: 0,
      limit: 1
    )
  end

  def solr_query
    Search::CSAQuery.new(
      state: state,
      csa_years: (csa_years.presence || default_csa_year),
      offset: offset,
      limit: limit,
      sort_name: sort_name
    )
  end

  # SearchControllerConcerns
  def serialized_schools
    # Using a plain rubo object to convert domain object to json
    # decided not to use jbuilder. Dont feel like it adds benefit and
    # results in less flexible/resuable code. Could use
    # active_model_serializers (included with rails 5) but it's yet another
    # gem...
    return [] if csa_available_years.empty?
    @_serialized_schools ||= schools.map do |school|
      Api::SchoolSerializer.new(school).to_hash.tap do |s|
        s.except(not_default_extras - extras)
      end
    end
  end

  private
  

  def default_csa_year
    csa_available_years.first
  end

  def choose_meta_tag_implementation
    MetaTag::CollegeSuccessAwardsMetaTags
  end

  def breadcrumbs
    @_breadcrumbs ||= [
      {
        text: StructuredMarkup.state_breadcrumb_text(state),
        url: state_url(state_params(state))
      },
      {
        text: 'College Success Awards',
        url: state_college_success_awards_list_url(state_params(state))
      }
    ]
  end

  # StructuredMarkup
  def prepare_json_ld
    breadcrumbs.each { |bc| add_json_ld_breadcrumb(bc) }
  end

  # AdvertisingConcerns
  def ad_targeting_props
    raise 'Not defined'
    {
      page_name: "SchoolS",
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
      hash[PageAnalytics::PAGE_NAME] = 'GS:Badges:CSA'
      hash[PageAnalytics::STATE] = state.upcase if state
      hash[PageAnalytics::ENV] = ENV_GLOBAL['advertising_env']
      hash[PageAnalytics::GS_BADGE] = 'CSAWinner'
    end
  end

  # Paginatable
  def default_limit
    25
  end

  def redirect_unless_valid_search_criteria
    true
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