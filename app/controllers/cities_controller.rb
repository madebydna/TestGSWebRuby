class CitiesController < ApplicationController
  include CommunityParams
  include AdvertisingConcerns
  include PageAnalytics
  include CommunityConcerns

  layout 'application'
  before_filter :redirect_unless_valid_city

  def show
    set_city_meta_tags
    @schools = serialized_schools
    @breadcrumbs = breadcrumbs
    @locality = locality
  end

  private

  def set_city_meta_tags
    set_meta_tags(alternate: {en: url_for(lang: nil), es: url_for(lang: :es)},
                  title: cities_title,
                  description: cities_description,
                  canonical: city_url(state: States.state_path(state), city: city.downcase))
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
      page_name: "GS:City:Home",
      template: "search",
    }.tap do |hash|
      # these intentionally capitalized to match property names that have
      # existed for a long time. Not sure if it matters
      hash[:City] = city.gs_capitalize_words if city
      hash[:State] = state if state
      hash[:level] = level_codes.map { |s| s[0] } if level_codes.present?
      hash[:county] = county_record&.name if county_record
    end
  end

  # PageAnalytics
  def page_analytics_data
    {}.tap do |hash|
      # placeholder
    end
  end

  def locality
    @_locality ||= begin
      Hash.new.tap do |cp|
        cp[:city] = city_record.name
        cp[:state] = state.upcase
        cp[:county] = city_record.county.name
      end
    end
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
  end

  def redirect_unless_valid_city
    redirect_to(state_path(States.state_path(state_name)), status: 301) unless city_record
  end

  def default_extras
    %w(summary_rating enrollment review_summary)
  end
end
