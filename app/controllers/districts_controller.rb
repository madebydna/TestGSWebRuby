class DistrictsController < ApplicationController
  include CommunityParams
  include AdvertisingConcerns
  include PageAnalytics
  include CommunityConcerns

  CACHE_KEYS_FOR_READER = %w(district_schools_summary district_characteristics)


  layout 'application'
  before_filter :redirect_unless_valid_district
  before_action :redirect_to_canonical_url

  def show
    @locality = locality
    @school_levels = school_levels
    @breadcrumbs = breadcrumbs
    @top_schools =  top_rated_schools
    @hero_data = hero_data
    @academics_props = district_record.academics_props(district_cache_data_reader)
    @reviews = reviews_formatted.reviews_list
    gon.homes_and_rentals_service_url = ENV_GLOBAL['homes_and_rentals_service_url']
    set_district_meta_tags
    set_ad_targeting_props
    set_page_analytics_data
  end

  private

  def district_cache_data_reader
    @_district_cache_data_reader ||= DistrictCacheDataReader.new(district_record, district_cache_keys: ['test_scores_gsdata', 'district_characteristics'])
  end

  def set_district_meta_tags
    district_params_hash = district_params(state, district_record.city, district)
    set_meta_tags(alternate: {en: url_for(lang: nil), es: url_for(lang: :es)},
                  title: districts_title,
                  description: districts_description,
                  canonical: city_district_url(state: district_params_hash[:state], city: district_params_hash[:city], district: district_params_hash[:district]))
  end

  def build_header_narration
    "#{district_record.name.gs_capitalize_words} #{t('controllers.districts_controller.District header narration')} #{city}, #{state.upcase}" if largest_district_in_city?
  end

  def largest_district_in_city?
    return false if city_record.nil?
    # check city cache for district_content - if district id in first hash of cache is equal to this district id it is the largest district by enrollment
    district_record.id == city_key_value(:id)
  end

# rubocop:disable Lint/SafeNavigationChain
  def city_key_value(key)
    (district_content(decorated_city)&.first || {}).fetch(key, nil)
  end
# rubocop:enable Lint/SafeNavigationChain

  def districts_title
    additional_district_text = state.downcase == 'dc' ? ', DC' : ''
    "#{district_record.name.gs_capitalize_words}#{additional_district_text} School District in #{district_record.city}, #{district_record.state}. | GreatSchools"
  end

  def districts_description
    "Information to help parents choose the right public school for their children in the #{district_record.name.gs_capitalize_words}."
  end

  def districts_state_text
    state.downcase == 'dc' ? '' : "#{district_record.name.gs_capitalize_words} #{state_name.gs_capitalize_words} "
  end

  # AdvertisingConcerns
  def ad_targeting_props
    {
      page_name: "GS:District:Home"
    }.tap do |hash|
      # these intentionally capitalized to match property names that have
      # existed for a long time. Not sure if it matters (comment ported over from previous version of controller)
      hash[:City] = city.gs_capitalize_words if city
      hash[:State] = state.upcase if state
      hash[:county] = county_record.name if county_record
    end
  end

  # PageAnalytics
  def page_analytics_data
    {}.tap do |hash|
      hash[PageAnalytics::PAGE_NAME] = 'GS:District:Home'
      hash[PageAnalytics::CITY] = city.gs_capitalize_words if city
      hash[PageAnalytics::STATE] = state.upcase if state
      hash[PageAnalytics::COUNTY] = county_record.name if county_record
      hash[PageAnalytics::ENV] = advertising_env
    end
  end

  def locality
    @_locality ||= begin
      Hash.new.tap do |cp|
        cp[:district_id] = district_record.id
        cp[:name] = district_record.name
        cp[:address] = district_record.mail_street if district_record.mail_street.present?
        cp[:city] = district_record.city
        cp[:lat] = district_record&.lat
        cp[:lon] = district_record&.lon
        cp[:stateLong] = state_name.gs_capitalize_words
        cp[:stateShort] = state.upcase
        cp[:searchResultBrowseUrl] = search_district_browse_path(
          state: gs_legacy_url_encode(States.state_name(state)),
          city: gs_legacy_url_encode(city),
          district_name: gs_legacy_url_encode(district),
          trailing_slash: true
        )
        cp[:mobilityURL] = ENV_GLOBAL['mobility_url']
        cp[:zipCode] = district_record.mail_zipcode[0..4]
        cp[:phone] = district_record.phone if district_record.phone.present?
        cp[:districtUrl] = prepend_http district_record.home_page_url if district_record.home_page_url.present?
      end
    end
  end

  def hero_data
    @_hero_data ||= begin
      Hash.new.tap do |hs|
        hs[:schoolCount] = district_record.num_schools
        hs[:enrollment] = district_enrollment
        hs[:grades] = GradeLevelConcerns.human_readable_level(district_record.level)
        hs[:narration] = build_header_narration
      end
    end
  end

  def district_enrollment
    @_district_enrollment ||= decorated_district.enrollment
  end

  def breadcrumbs
    canonical_district_params = district_params(state, district_record.city, district)
    @_district_breadcrumbs ||= [
      {
        text: StructuredMarkup.state_breadcrumb_text(state),
        url: state_url(state_params(state))
      },
      {
        text: StructuredMarkup.city_breadcrumb_text(state: state, city: city),
        url: city_url(city_params(state, city))
      },
      {
        text: district_record.name&.gs_capitalize_words,
        url: city_district_url(state: canonical_district_params[:state], city: canonical_district_params[:city], district: canonical_district_params[:district])
      }
    ]
  end

  def school_count(key)
    district_cache_contents[key] if district_cache_contents && district_cache_contents[key]
  end

  def district_cache_level_codes
    @_district_cache_level_codes ||= begin
      decorated_district.cache_data.dig("district_schools_summary","school counts by level code") || {}
    end
  end

  def district_cache_school_types
    @_district_cache_school_types ||= begin
      decorated_district.cache_data.dig("district_schools_summary","school counts by type") || {}
    end
  end

  def district_cache_contents
    @_district_cache_school_levels ||= begin
      {}.tap do |st|
        st["charter"] = district_cache_school_types["charter"] || 0
        st["public"] = district_cache_school_types["public"] || 0
        st["preschool"] = district_cache_level_codes["p"] || 0
        st["elementary"] = district_cache_level_codes["e"] || 0
        st["middle"] = district_cache_level_codes["m"] || 0
        st["high"] = district_cache_level_codes["h"] || 0
        st["all"] = district_record.num_schools
      end
    end
  end

  def decorated_district
    @_decorated_district ||= DistrictCache.cached_results_for([district_record], CACHE_KEYS_FOR_READER).decorate_districts([district_record]).first
  end

  def decorated_city
    @_decorated_city ||= CityCacheDecorator.for_city_and_keys(city_record, 'district_content')
  end

  def reviews
    @_reviews ||= 
      Review
        .active
          .where(school_id: 
            School.on_db(district_record.state.downcase) { School.active.where(district_id: district_record.id).ids },
            state: district_record.state.downcase)
            .where(review_question_id: 1)
              .where.not(comment: nil)
                .includes(:answers, :votes, question: :review_topic)
                  .order(id: :desc)
                    .limit(3)
                      .extend(SchoolAssociationPreloading).preload_associated_schools!
  end

  def reviews_formatted
    @_reviews_formatted ||= CommunityProfiles::Reviews.new(reviews, review_questions, district_record)
  end

  def review_questions
    @_review_questions ||= CommunityProfiles::ReviewQuestions.new(district_record)
  end

  # StructuredMarkup
  def prepare_json_ld
    breadcrumbs.each { |bc| add_json_ld_breadcrumb(bc) }
    if district_record.present?
      add_json_ld({
                      "@context" => "http://schema.org",
                      "@type" => "EducationalOrganization",
                      'name' => district_record.name.gs_capitalize_words,
                      'address' => {
                          '@type' => 'PostalAddress',
                          'streetAddress' => district_record.street,
                          'addressLocality' => district_record.city,
                          'addressRegion' => district_record.state,
                          'postalCode' => district_record.zipcode
                      },
                      'telephone' => district_record.phone
                  })
    end
  end

  def redirect_unless_valid_district
    redirect_to(city_path(state: state_name, city: city&.downcase), status: 301) unless district_record
  end

  def redirect_to_canonical_url
    canonical_district_params = district_params(state, district_record.city, district)
    # this prevents an endless redirect loop for the profile pages
    # because of ApplicationController::url_options
    canonical_path = remove_query_params_from_url( city_district_path(state: canonical_district_params[:state], city: canonical_district_params[:city], district: canonical_district_params[:district]), [:lang] )

    # Add a trailing slash to the request path, only if one doesn't already exist.
    unless canonical_path == with_trailing_slash(request.path)
      redirect_to add_query_params_to_url(
                      city_district_path(state: canonical_district_params[:state], city: canonical_district_params[:city], district: canonical_district_params[:district]),
                      true,
                      request.query_parameters
                  ), status: :moved_permanently
    end
  end

  def default_extras
    %w(summary_rating enrollment review_summary students_per_teacher)
  end

end
