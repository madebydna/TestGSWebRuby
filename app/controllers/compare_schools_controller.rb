class CompareSchoolsController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams
  include SearchControllerConcerns
  include SearchTableConcerns
  include AdvertisingConcerns
  include PageAnalytics

  layout "application"
  before_filter :redirect_unless_school_id_and_state

  set_additional_js_translations(
    breakdowns: [:lib, :breakdowns]
  )
  
  def show
    set_login_redirect
    gon.compare = {
      schools: serialized_schools,
      breakdown: ethnicity,
      sort: sort_name,
      tableHeaders: compare_schools_table_headers,
    }.merge(Api::SortOptionSerializer.new(solr_query.valid_static_sort_fields + ['testscores']).to_hash)
    @radius = radius
    set_meta_tags(MetaTag::CompareMetaTags.new(self).meta_tag_hash)
    set_page_analytics_data
  end

  private

  # SearchRequestParams
  def sort_name
    super || 'distance'
  end

  def fetch_pinned_school
    query_type = Search::SolrSchoolQuery
    query_type.new(school_keys: [[state,school_id]]).search
  end

  # SearchControllerConcerns
  def schools
    @_schools ||= begin
      pinned_school = fetch_pinned_school
      results = (page_of_results + pinned_school).uniq
      decorate_schools(results)
    end
  end

  # PageAnalytics
  def page_analytics_data
    {}.tap do |hash|
      hash[PageAnalytics::PAGE_NAME] = 'GS:Compare:Home'
      hash[PageAnalytics::STATE] = state.upcase if state
      hash[PageAnalytics::ENV] = advertising_env
      hash[PageAnalytics::SCHOOL_ID] = school_id
    end
  end

  def breakdown
    params[:breakdown]
  end
  
  # solr params that overwrites
  def limit
    default_limit
  end

  def default_limit
    100
  end

  # SearchRequestParams
  def default_radius
    5
  end

  def redirect_unless_school_id_and_state
    redirect_to home_path unless state && school_id
  end

  def extras
    default_extras + extras_param
  end

  def extras_param
    params[:extras]&.split(',') || []
  end

  def default_extras
    %w(summary_rating enrollment review_summary saved_schools pinned_school ethnicity_test_score_rating distance)
  end

  def not_default_extras
    []
  end

end
