class CompareSchoolsController < ApplicationController
  include Pagination::PaginatableRequest
  include SearchRequestParams
  include CompareControllerConcerns
  include AdvertisingConcerns
  include PageAnalytics

  layout "application"
  before_filter :redirect_unless_school_id_and_state

  def show
    set_login_redirect
    gon.compare = {
      schools: serialized_schools,
      breakdown: ethnicity,
      sort: sort_name,
      tableHeaders: table_headers
    }
    set_compare_meta_tags
  end

  def fetch_schools
    render json: {
      links: {
        prev: self.prev_offset_url(page_of_results),
        next: self.next_offset_url(page_of_results),
      },
      items: serialized_schools,
      tableHeaders: table_headers
    }.merge(Api::PaginationSummarySerializer.new(page_of_results).to_hash)
    .merge(Api::PaginationSerializer.new(page_of_results).to_hash)
  end

  private

  # PageAnalytics
  def page_analytics_data
    {}.tap do |hash|
      hash[PageAnalytics::PAGE_NAME] = 'GS:Compare:Home'
      hash[PageAnalytics::STATE] = state.upcase if state
      hash[PageAnalytics::ENV] = advertising_env
      hash[PageAnalytics::SCHOOL_ID] = school_id
    end
  end

  def set_compare_meta_tags
    set_meta_tags(title: compare_title)
  end

  def compare_title
    "Compare #{base_school_for_compare&.name} to nearby schools - #{base_school_for_compare&.city}, #{state_name&.gs_capitalize_words} - #{state.upcase} | GreatSchools"
  end

  def breakdown
    params[:breakdown]
  end

  def ethnicity
    pinned_school_ethnicity_breakdowns.include?(breakdown) ? breakdown : pinned_school_ethnicity_breakdowns.sort.first
  end

  def base_school_for_compare
    @_base_school_for_compare ||= begin
      pinned_school = School.on_db(state).find(school_id)
      pinned_school = send("add_ratings", pinned_school) if respond_to?("add_ratings", true)
      SchoolCacheQuery.decorate_schools([pinned_school], *cache_keys).first
    rescue
      nil
    end
  end

  def pinned_school_ethnicity_breakdowns
    @breakdowns ||= begin
      base_school_for_compare&.ethnicity_breakdowns || []
    end
  end

  def school_id
    params[:schoolId]&.to_i
  end

  def level_codes
    params[:gradeLevels] || params[:level_code].split(",")
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

  def merge_school_keys
    (FavoriteSchool.saved_school_list(current_user.id) + cookies_school_keys).uniq
  end

  def cookies_school_keys
    # If a user saves a school and then removes it, the cookie will be set as '[]'. Code below will return [] in that case.
    cookies[:gs_saved_schools] ? JSON.parse(cookies[:gs_saved_schools]).map {|hash| [hash['state']&.downcase, hash['id']&.to_i]} : []
  end

  def default_extras
    %w(ratings characteristics review_summary saved_schools pinned_school ethnicity_test_score_rating distance)
  end
end
