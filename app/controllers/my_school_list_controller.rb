# frozen_string_literal: true

class MySchoolListController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams
  include SearchControllerConcerns
  include SearchTableConcerns
  include AdvertisingConcerns
  include PageAnalytics


  layout 'application'

  def show
    gon.search = {
      schools: serialized_schools
    }.tap do |props|
      props.merge!(Api::PaginationSummarySerializer.new(page_of_results).to_hash)
      props[:resultSummary] = I18n.t('.search.Your school list is empty') if serialized_schools.empty?
      props.merge!(Api::PaginationSerializer.new(page_of_results).to_hash)
      props.merge!(Api::SortOptionSerializer.new(page_of_results.sortable_fields).to_hash)
      props[:mslStates] = msl_states
      props[:stateSelect] = state_select
      # props.merge!()
      props[:searchTableViewHeaders] = {
        'Overview' => overview_header_hash,
        'Equity' => equity_header_hash,
        'Academic' => academic_header_hash
      }
    end

    set_ad_targeting_props
    set_page_analytics_data
  end

  # SearchControllerConcerns

  def query
    if school_keys.present?
      solr_query
    else
      null_query
    end
  end

  def default_limit
    25
  end

  # SearchRequestParams

  def school_keys
    saved_school_keys || []
  end

  def default_extras
    %w(summary_rating distance assigned enrollment students_per_teacher review_summary all_ratings saved_schools)
  end

  def not_default_extras
    []
  end

  # AdvertisingConcerns
  def ad_targeting_props
    {
      page_name: "GS:MySchoolList",
      template: "myschoollist",
    }
  end

  # PageAnalytics
  def page_analytics_data
    {}.tap do |hash|
      hash[PageAnalytics::PAGE_NAME] = 'GS:MySchoolList'
    end
  end

end