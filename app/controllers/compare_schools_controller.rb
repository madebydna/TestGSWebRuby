class CompareSchoolsController < ApplicationController
  # include CompareSchoolsConcerns
  # include SearchHelper
  # include SchoolHelper

  include Pagination::PaginatableRequest
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
      sort: sort,
      tableHeaders: table_headers
    }
    # LEGACY################################################
    # gon.pagename = 'CompareSchoolsPage'
    # page_title = 'Compare Schools'
    # gon.pageTitle = page_title
    #
    # prepare_schools
    # set_back_to_search_results_instance_variable
    #
    # set_meta_tags title: page_title,
    #               description:'Compare schools to find the right school for your family',
    #               robots: 'noindex'
    # set_data_layer_variables
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

  def state
    #TODO DRY this up - exists in community params as well
    return nil unless params[:state].present?
    state_param = params[:state]

    if States.is_abbreviation?(state_param)
      state_param
    else
      States.abbreviation(state_param.gsub('-', ' ').downcase)
    end
  end

  def breakdown
    params[:breakdown]
  end

  def ethnicity
    pinned_school_ethnicity_breakdowns.include?(breakdown) ? breakdown : pinned_school_ethnicity_breakdowns.sort.first
  end

  def pinned_school_ethnicity_breakdowns
    @breakdowns ||=begin
      school = School.on_db("#{state}").find("#{school_id}")
      school = send("add_ratings", school) if respond_to?("add_ratings", true)
      SchoolCacheQuery.decorate_schools([school], *cache_keys).first.ethnicity_breakdowns
    end
  end

  def school_id
    params[:schoolId]
  end

  def sort
    params[:sort]
  end

  def lat
    params[:lat]
  end

  def lon
    params[:lon]
  end

  def level_codes
    params[:gradeLevels] || params[:level_code].split(",")
  end

  def sort_name
    params[:sort]
  end

  def entity_types
    params[:st] & ['public', 'private', 'charter']
  end

  def redirect_unless_school_id_and_state
    redirect_to home_path unless state && school_id
  end

  # def set_data_layer_variables
  #   state = @state.try(:upcase) if @state
  #
  #   data_layer_gon_hash.merge!(
  #     {
  #       'page_name' => 'GS:Compare',
  #       'State' => state,
  #     }
  #   )
  # end

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

  def saved_school_keys
    current_user ? merge_school_keys : cookies_school_keys
  end

  def default_extras
    %w(ratings characteristics review_summary saved_schools pinned_school ethnicity_test_score_rating)
  end
end
