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
    @districts = districts_by_city
    @school_levels = school_levels
  end

  private

  def districts_by_city
    School.on_db(state)
      .where(city: city_record.name, active: 1)
      .joins('left join district on district.id = school.district_id')
      .where('district.charter_only = 0')
      .group('district.id')
      .pluck('district.name', 'district.level_code', 'district.num_schools', 'district.city')
      .map {|school_record| {:districtName=> school_record[0],
                             :grades=>LevelCode.full_from_all_grades(school_record[1]),
                             :numSchools=>school_record[2],
                             :url=>district_url(state: state_name, city: gs_legacy_url_encode(school_record[3]), district: gs_legacy_url_encode(school_record[0]))}}
  end

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

  def city_cache_school_levels
    @_city_cache_school_levels ||= begin
      cc = CityCache.for_city_and_name('school_levels', city_record.id)
      JSON.parse(cc['value']) if cc.present?
    end
  end

  def school_levels
    @_school_levels ||= begin
      {}.tap do |sl|
        sl[:all] = school_count('all')
        sl[:public] = school_count('public')
        sl[:private] = school_count('private')
        sl[:charter] = school_count('charter')
        sl[:preschool] = school_count('preschool')
        sl[:elementary] = school_count('elementary')
        sl[:middle] = school_count('middle')
        sl[:high] = school_count('high')
      end
    end
  end

  def school_count(key)
    city_cache_school_levels[key].first['city_value'] if city_cache_school_levels && city_cache_school_levels[key]
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
