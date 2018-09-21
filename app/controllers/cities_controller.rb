class CitiesController < ApplicationController
  include CommunityParams
  include AdvertisingConcerns
  include PageAnalytics
  include CommunityConcerns

  layout 'application'
  before_filter :redirect_unless_valid_city

  def show
    set_city_meta_tags
    @breadcrumbs = breadcrumbs
    @locality = locality
    @school_levels = school_levels
    @top_schools =  top_rated_schools
    @districts = district_content(city_record.id)
    set_ad_targeting_props
    set_page_analytics_data
    Gon.set_variable('homes_and_rentals_service_url', ENV_GLOBAL['homes_and_rentals_service_url'])
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
    CityCache.school_levels(city_record.id)[key].first['city_value'] if CityCache.school_levels(city_record.id) && CityCache.school_levels(city_record.id)[key]
  end

  def locality
    @_locality ||= begin
      Hash.new.tap do |cp|
        cp[:city] = city_record.name
        cp[:stateLong] = state_name.gs_capitalize_words
        cp[:stateShort] = state.upcase
        cp[:county] = county_record&.name
        cp[:searchResultBrowseUrl] = search_city_browse_path(city_params(state, city))
        cp[:zip] = get_zip
      end
    end
  end

  def get_zip
    zip = district_content(city_record.id).find do |dc|
      break dc[:zip] if dc[:zip].present?
    end
    zip ||= @schools.find do |s|
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
        url: ""
      }
    ]
  end

  # StructuredMarkup
  def prepare_json_ld
    breadcrumbs.each { |bc| add_json_ld_breadcrumb(bc) }
  end

  def redirect_unless_valid_city
    redirect_to(state_path(States.state_path(state_name)), status: 301) unless city_record
  end

  def default_extras
    %w(summary_rating enrollment review_summary students_per_teacher)
  end
end
