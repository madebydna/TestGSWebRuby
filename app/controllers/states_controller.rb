class StatesController < ApplicationController
  include CommunityParams
  include SeoHelper
  include SearchHelper
  include SchoolHelper
  include StatesMetaTagsConcerns
  include CommunityTabConcerns
  include PopularCitiesConcerns
  include CommunityConcerns

  before_action :set_city_state
  before_action :set_login_redirect
  layout 'application'

  set_additional_js_translations(
    top_schools: [:community, :top_schools]
  )

  def show
    #PT-1205 Special case for dc to redirect to /washington-dc/washington city page
    if @state[:short] == 'dc'
      return redirect_to city_path('washington-dc', 'washington'), status: 301
    end
    # set cache-control to expire in one day
    cache_time = ENV_GLOBAL['state_page_cache_time']
    expires_in(cache_time.to_i, public: true, must_revalidate: true) if cache_time.present?

    @level_code = []
    @csa_years = []
    @csa_module = csa_state_solr_query.present?
    @breadcrumbs = breadcrumbs
    @locality = locality
    @cities = cities_data
    @top_schools = top_rated_schools
    @summary_type = summary_rating_type
    @districts = district_largest.to_hash
    @school_count = school_levels.try(:fetch, :all, nil).presence || School.within_state(state).count
    @school_levels = school_levels
    @reviews = reviews_formatted
    @students = students
    gon.dependencies = {
      highcharts: ActionController::Base.helpers.asset_path('highcharts.js')
    }
    write_meta_tags
    gon.pagename = 'GS:State:Home'
    @params_hash = parse_array_query_string(request.query_string)
    gon.state_abbr = @state[:short]
    @ad_page_name = :State_Home_Standard
    @show_ads = PropertyConfig.advertising_enabled?
    gon.show_ads = show_ads?
    ad_setTargeting_through_gon
    data_layer_through_gon
    @academics = academics
    @toc = toc.state_toc
  end

  def school_state_title
    States.capitalize_any_state_names(@state[:long])
  end

  def academics
    CommunityProfiles::Academics.state_academics_props(state_cache_data_reader)
  end

  # ::SearchControllerConcerns
  def solr_query
    query_type = Search::SolrSchoolQuery
    query_type.new(
        state: @state[:short].upcase,
        level_codes: @level_code.compact,
        limit: default_top_schools_limit,
        sort_name: 'rating',
        ratings: (1..10).to_a,
        csa_years: @csa_years.presence
    )
  end

  def csa_state_solr_query
    @_csa_state_solr_query ||= begin
      csa_badge = ['*']
      query_type = Search::SolrSchoolQuery
      query_type.new(
          state: @state[:short].upcase,
          limit: 1,
          csa_years: csa_badge.presence
      ).search
    end
  end

  def reviews
    @_reviews ||=
      Review
        .active
        .where(state: @state[:short])
        .where(review_question_id: 1)
        .where.not(comment: nil)
        .includes(:answers, :votes, question: :review_topic)
        .order(id: :desc)
        .limit(3)
        .extend(SchoolAssociationPreloading).preload_associated_schools!
  end

  def reviews_formatted
    @_reviews_formatted ||= begin
      reviews.map do |review|
        review_school = School.find_by_state_and_id(review.state, review.school_id)

        if review_school.present? && review_school.active?
          Hash.new.tap do |rp|
            rp["avatar"] = UserReviews::USER_TYPE_AVATARS[review.user_type]
            rp["five_star_review"] = five_star_review_hash(review)
            rp["id"] = review.id
            rp["most_recent_date"] = I18n.l(review.created, format: "%B %d, %Y")
            rp[:school_name] = review_school.name
            rp[:school_path] = school_path(review_school)
            rp["user_type_label"] = t(review.user_type).gs_capitalize_first
          end
        end
      end.compact
    end
  end

  def five_star_review_hash(review)
    Hash.new.tap do |rp|
      rp[:answer] = review.answer
      rp[:comment] = review.comment
      rp[:topic_label] = review.question.review_topic.label
    end
  end

  def students
    @_students ||= CommunityProfiles::Students.new(cache_data_reader: state_cache_data_reader)
  end

  def district_largest
    @_district_largest ||= CommunityProfiles::DistrictLargest.new(cache_data_reader: state_cache_data_reader)
  end

  def state_cache_data_reader
    @_state_cache_data_reader ||= StateCacheDataReader.new(state)
  end

  def school_count(key)
    cache_school_levels.try(:fetch, key, nil)
  end

  def cache_school_levels
    state_cache_data_reader.school_levels
  end

  private

  def page_view_metadata
    @page_view_metadata ||= (
      page_view_metadata = {}

      page_view_metadata['page_name'] = gon.pagename || "GS:State:Home"
      page_view_metadata['State']      = @state[:short].upcase # abbreviation
      page_view_metadata['editorial']  = 'FindaSchoo'
      page_view_metadata['template']   = "ros" # use this for page name - configured_page_name

      page_view_metadata

    )
  end

  def ad_setTargeting_through_gon
    @ad_definition = Advertising.new
    if show_ads?
      page_view_metadata.each do |key, value|
        ad_targeting_gon_hash[key] = value
      end
    end
  end

  def data_layer_through_gon
    data_layer_gon_hash.merge!(page_view_metadata)
  end

  private

  def write_meta_tags
    method_base = "#{controller_name}_#{action_name}"
    title_method = "#{method_base}_title".to_sym
    description_method = "#{method_base}_description".to_sym
    set_meta_tags(
      title: send(title_method),
      description: send(description_method),
      alternate: {en: url_for(lang: nil), es: url_for(lang: :es)},
      canonical: state_url(state_params(@state[:short]))
    )
  end

  def breadcrumbs
    @_state_breadcrumbs ||= [
      {
        text: StructuredMarkup.home_breadcrumb_text,
        url: home_path
      },
      {
        text: StructuredMarkup.state_breadcrumb_text(@state[:short].upcase),
        url: state_url(state_params(@state[:short]))
      }
    ]
  end

  # StructuredMarkup
  def prepare_json_ld
    breadcrumbs.each { |bc| add_json_ld_breadcrumb(bc) }
  end

  def toc
    CommunityProfiles::Toc.new(csa_module: @csa_module, school_districts: @districts, academics: @academics, student_demographics: @students, reviews: @reviews)
  end

  def locality
    @_locality ||= begin
      Hash.new.tap do |cp|
        cp[:nameLong] = States.capitalize_any_state_names(@state[:long])
        cp[:nameShort] = @state[:short].upcase
        cp[:citiesBrowseUrl] = cities_list_path(
          state_name: gs_legacy_url_encode(@state[:long]),
          state_abbr: @state[:short],
          trailing_slash: true
        )
        cp[:districtsBrowseUrl] = districts_list_path(
          state_name: gs_legacy_url_encode(@state[:long]),
          state_abbr: @state[:short],
          trailing_slash: true
        )
        cp[:searchResultBrowseUrl] = search_state_browse_path(gs_legacy_url_encode(@state[:long]))
        cp[:stateCsaBrowseUrl] = state_college_success_awards_list_path(
          state: gs_legacy_url_encode(@state[:long]),
          trailing_slash: true
        ) if @csa_module
      end
    end
  end

  def cities_data
    top_cities = browse_top_cities

    @_cities_data ||= begin
      top_cities.map do |city|
        Hash.new.tap do |cp|
          cp[:name] = city.name
          cp[:population] = city.population
          cp[:state] = city.state
          cp[:url] = city_path(
            state: gs_legacy_url_encode(States.state_name(city.state)),
            city: gs_legacy_url_encode(city.name),
            trailing_slash: true
          )
        end
      end
    end
  end

  def default_extras
    %w(summary_rating enrollment review_summary)
  end

end