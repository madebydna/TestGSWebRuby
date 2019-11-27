class CitiesController < ApplicationController
  include CommunityParams
  include AdvertisingConcerns
  include PageAnalytics
  include CommunityConcerns

  layout 'application'
  before_filter :redirect_unless_valid_city

  set_additional_js_translations(
    top_schools: [:community, :top_schools]
  )

  def show
    cache_time = ENV_GLOBAL['city_page_cache_time']
    expires_in(cache_time.to_i, public: true, must_revalidate: true) if cache_time.present?

    @level_code = []
    @csa_years = []
    set_city_meta_tags
    @top_schools =  top_rated_schools
    @breadcrumbs = breadcrumbs
    @school_levels = school_levels
    @districts = district_content(decorated_city)
    @reviews = reviews_formatted.reviews_list
    @locality = locality
    @csa_module = csa_state_solr_query.present?
    @neighboring_cities = neighboring_cities_data
    gon.homes_and_rentals_service_url = ENV_GLOBAL['homes_and_rentals_service_url']
    set_ad_targeting_props
    set_page_analytics_data
    @toc = toc
  end

  private

  def set_city_meta_tags
    city_params_hash = city_params(state, city)
    set_meta_tags(alternate: {en: url_for(lang: nil), es: url_for(lang: :es)},
                  title: cities_title,
                  description: cities_description,
                  canonical: city_url(state: city_params_hash[:state], city: city_params_hash[:city]),
                  noindex: (school_levels.try(:fetch, :all, nil) || 0 ) < 3)
  end

  def cities_title
    additional_city_text = state.downcase == 'dc' ? ', DC' : ''
    city_state_text = "#{city_record.name.gs_capitalize_words}, #{state.upcase} "

    t('controllers.cities_controller.meta_title', city_name: city_record.name.gs_capitalize_words, additional_city_text: additional_city_text, city_and_state: city_state_text)
  end

  def cities_description
    state_text = state.downcase == 'dc' ? "#{state.upcase}" : "#{state_name.gs_capitalize_words}"

    t('controllers.cities_controller.meta_description', city_name: city_record.name.gs_capitalize_words, state_text: state_text, state_abbrev: state.upcase)   
  end

  def cities_state_text
    state.downcase == 'dc' ? '' : "#{city_record.name.gs_capitalize_words}, #{state.upcase} "
  end

  # ::SearchControllerConcerns
  def solr_query
    query_type = Search::SolrSchoolQuery
    query_type.new(
        city: city,
        state: state,
        district_name: district_record&.name,
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
          state: state.upcase,
          limit: 1,
          csa_years: csa_badge.presence
      ).search
    end
  end 

  def reviews
    @_reviews ||=
      Review
        .active
          .where(school_id:
            School.on_db(city_record.state.downcase) { School.active.where(city: city_record.name).ids },
            state: city_record.state.downcase)
            .where(review_question_id: 1)
              .where.not(comment: nil)
                .includes(:answers, :votes, question: :review_topic)
                  .order(id: :desc)
                    .limit(3)
                      .extend(SchoolAssociationPreloading).preload_associated_schools!
  end

  def reviews_formatted
    @_reviews_formatted ||= CommunityProfiles::Reviews.new(reviews, review_questions, city_record)
  end

  def review_questions
    @_review_questions ||= CommunityProfiles::ReviewQuestions.new(city_record)
  end

  # AdvertisingConcerns
  def ad_targeting_props
    {
      page_name: "GS:City:Home"
    }.tap do |hash|
      # these intentionally capitalized to match property names that have
      # existed for a long time. Not sure if it matters
      hash[:City] = city.gs_capitalize_words if city
      hash[:State] = state.upcase if state
      hash[:county] = county_record.name if county_record
    end
  end

  # PageAnalytics
  def page_analytics_data
    {}.tap do |hash|
      hash[PageAnalytics::PAGE_NAME] = 'GS:City:Home'
      hash[PageAnalytics::CITY] = city.gs_capitalize_words if city
      hash[PageAnalytics::STATE] = state.upcase if state
      hash[PageAnalytics::COUNTY] = county_record.name if county_record
      hash[PageAnalytics::ENV] = ENV_GLOBAL['advertising_env']
      hash[PageAnalytics::GS_BADGE] = 'CSAnullstate' unless has_csa_schools?
    end
  end

  def school_count(key)
    cache_school_levels[key].first['city_value'] if cache_school_levels && cache_school_levels[key]
  end

  def cache_school_levels
    decorated_city.cache_data['school_levels']
  end

  def decorated_city
    @_decorated_city ||= CityCacheDecorator.for_city_and_keys(city_record, 'school_levels', 'district_content')
  end

  def locality
    @_locality ||= begin
      Hash.new.tap do |cp|
        cp[:city] = city_record.name
        cp[:stateLong] = state_name.gs_capitalize_words
        cp[:stateShort] = state.upcase
        cp[:county] = county_record&.name
        cp[:searchResultBrowseUrl] = search_city_browse_path(city_params(state, city))
        cp[:stateCsaBrowseUrl] = state_college_success_awards_list_path(state_params(state_name)) if csa_state_solr_query.present?
        cp[:mobilityURL] = ENV_GLOBAL['mobility_url']
        cp[:zip] = get_zip
        cp[:lat] = fetch_district_attr(decorated_city, :lat) || city_record&.lat
        cp[:lon] = fetch_district_attr(decorated_city, :lon) || city_record&.lon
      end
    end
  end

  def get_zip
    zip = district_content(decorated_city).find do |dc|
      break dc[:zip] if dc[:zip].present?
    end
    if @top_schools.present?
      zip ||= @top_schools[:schools][:elementary].find do |s|
        break s[:address][:zip] if s && s[:address].present? && s[:address][:zip].present?
      end
    end
    zip
  end

  def breadcrumbs
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

  TOC_CONFIG = {
    schools: { label: 'schools', anchor: '#schools' },
    school_districts: { label: 'districts', anchor: '#districts' },
    community_resources: { label: 'community_resources', anchor: '#mobility' },
    nearby_homes_for_sale: { label: 'nearby_homes_for_sale_and_rent', anchor: '#homes-and-rentals' },
    reviews: { label: 'reviews', anchor: '#reviews' },
    neighboring_cities: { label: 'neighboring_cities', anchor: '#neighboring-cities' }
  }

  def toc 
    toc_items = TOC_CONFIG.keys
    
    toc_items.delete(:reviews) if @reviews.empty?
    toc_items.delete(:school_districts) if @districts.empty?
    toc_items.delete(:neighboring_cities) if @neighboring_cities.empty?

    toc_items.map { |item| TOC_CONFIG[item] }
  end

  def neighboring_cities_data
    @_neighboring_cities_data ||= begin
      City.find_neighbors(city_record).map do |city|
        Hash.new.tap do |cp|
          cp[:name] = city.name
          cp[:url] = city_path(
            state: gs_legacy_url_encode(States.state_name(city.state)),
            city: gs_legacy_url_encode(city.name),
            trailing_slash: true
          )
        end
      end 
    end
  end 

  # StructuredMarkup
  def prepare_json_ld
    breadcrumbs.each { |bc| add_json_ld_breadcrumb(bc) }
    if city_record.present?
      add_json_ld({
                      "@context" => "http://schema.org",
                      "@type" => "City",
                      'name' => city,
                      'address' => {
                          '@type' => 'PostalAddress',
                          'addressRegion' => city_record.state,
                      }
                  })
    end
  end

  def redirect_unless_valid_city
    redirect_to(state_path(States.state_path(state_name)), status: 301) unless city_record
  end

  def default_extras
    %w(summary_rating enrollment review_summary students_per_teacher)
  end
end
