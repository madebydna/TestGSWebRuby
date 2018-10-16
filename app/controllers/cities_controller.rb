class CitiesController < ApplicationController
  include CommunityParams
  include AdvertisingConcerns
  include PageAnalytics
  include CommunityConcerns

  layout 'application'
  before_filter :redirect_unless_valid_city

  def show
    set_city_meta_tags
    @top_schools =  top_rated_schools
    @breadcrumbs = breadcrumbs
    @school_levels = school_levels
    @districts = district_content(decorated_city)
    # @reviews = reviews_formatted.reviews_list
    @locality = locality
    gon.homes_and_rentals_service_url = ENV_GLOBAL['homes_and_rentals_service_url']
    set_ad_targeting_props
    set_page_analytics_data
  end

  private

  def set_city_meta_tags
    city_params_hash = city_params(state, city)
    set_meta_tags(alternate: {en: url_for(lang: nil), es: url_for(lang: :es)},
                  title: cities_title,
                  description: cities_description,
                  canonical: city_url(state: city_params_hash[:state], city: city_params_hash[:city]))
  end

  def cities_title
    additional_city_text = state.downcase == 'dc' ? ', DC' : ''
    "#{city_record.name.gs_capitalize_words}#{additional_city_text} Schools - #{cities_state_text}School Ratings - Public and Private"
  end

  def cities_description
    "Find top-rated #{city_record.name} schools, read recent parent reviews, "+
      "and browse private and public schools by grade level in #{city_record.name}, #{state_name.gs_capitalize_words} (#{state.upcase})."
  end

  def cities_state_text
    state.downcase == 'dc' ? '' : "#{city_record.name.gs_capitalize_words} #{state_name.gs_capitalize_words} "
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
    zip ||= @top_schools[:schools][:elementary].find do |s|
      break s[:address][:zip] if s && s[:address].present? && s[:address][:zip].present?
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
