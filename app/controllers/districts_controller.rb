class DistrictsController < ApplicationController
  include CommunityParams
  include AdvertisingConcerns
  include PageAnalytics
  include CommunityConcerns

  CACHE_KEYS_FOR_READER = ['district_schools_summary', 'district_characteristics']

  layout 'application'
  before_filter :redirect_unless_valid_district

  def show
    # gon.pagename = 'DistrictHome'
    # @district = district
    # @ad_page_name = :District_Home # TODO verify name to use

    # @nearby_districts = @district.nearby_districts
    # @canonical_url = city_district_url(district_params_from_district(@district))

    # @top_schools = top_schools(@district, 4)
    # @params_hash = parse_array_query_string(request.query_string)
    # @show_ads = hub_show_ads? && PropertyConfig.advertising_enabled?
    @locality = locality
    @school_levels = school_levels
    @breadcrumbs = breadcrumbs
    @serialized_schools = serialized_schools
    @hero_stats = hero_stats
    @hero_narration =  build_header_narration
    set_district_meta_tags
    Gon.set_variable('homes_and_rentals_service_url', ENV_GLOBAL['homes_and_rentals_service_url'])
  end

  private

  def set_district_meta_tags
    district_params_hash = district_params(state, city, district)
    set_meta_tags(alternate: {en: url_for(lang: nil), es: url_for(lang: :es)},
                  title: districts_title,
                  description: districts_description,
                  canonical: city_district_url(state: district_params_hash[:state], city: district_params_hash[:city], district: district_params_hash[:district]))
  end

  def build_header_narration
    "#{district_record.name.gs_capitalize_words} #{t('controllers.districts_controller.District header narration')} #{city}, #{state.upcase}" if largest_district_in_city?
  end

  def largest_district_in_city?
    # check city cache for district_content - if district id in first hash of cache is equal to this district id it is the largest district by enrollment
    largest_district_id = city_key_value('id')
    largest_district_id == district_record.id
  end

  def city_cache_district_content
    @_city_cache_district_content ||= begin
      cc = CityCache.for_name_and_city_id('district_content', district_record.city_record.id)
      JSON.parse(cc.value) if cc.present?
    end
  end

# rubocop:disable Lint/SafeNavigationChain
  def city_key_value(key)
    city_cache_district_content&.first[key]&.first['city_value'] if city_cache_district_content&.first[key]
  end
# rubocop:enable Lint/SafeNavigationChain

  def districts_title
    additional_district_text = state.downcase == 'dc' ? ', DC' : ''
    "#{district_record.name.gs_capitalize_words}#{additional_district_text} School District in #{district_record.city}, #{district_record.state}."
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
      page_name: "GS:District:Home",
      template: "search"
    }.tap do |hash|
      # these intentionally capitalized to match property names that have
      # existed for a long time. Not sure if it matters
      hash[:City] = city.gs_capitalize_words if city
      hash[:State] = state if state
      hash[:District] = district if district
      hash[:level] = level_codes.map { |s| s[0] } if level_codes.present?
      hash[:county] = county_record.name if county_record
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
        cp[:district_id] = district_record.id
        cp[:name] = district_record.name
        cp[:address] = district_record.mail_street
        cp[:city] = district_record.city
        cp[:stateLong] = state_name.gs_capitalize_words
        cp[:stateShort] = state.upcase
        cp[:searchResultBrowseUrl] = search_district_browse_path(
          state: gs_legacy_url_encode(States.state_name(state)),
          city: gs_legacy_url_encode(city),
          district_name: gs_legacy_url_encode(district),
          trailing_slash: true
        )
        cp[:zipCode] = district_record.mail_zipcode[0..4]
        cp[:phone] = district_record.phone
        cp[:districtUrl] = prepend_http district_record.home_page_url
      end
    end
  end

  def hero_stats
    @_hero_stats ||= begin
      Hash.new.tap do |hs|
        hs[:schoolCount] = district_record.num_schools
        hs[:enrollment] = district_enrollment
        hs[:grades] = GradeLevelConcerns.human_readable_level(district_record.level)
      end
    end
  end

  def district_enrollment
    @_district_enrollment ||= begin
      decorated_district.cache_data['district_characteristics']['Enrollment'].first['district_value']
      rescue
        return nil
      end
  end

  def breadcrumbs
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
        url: ""
      }
    ]
  end

  def school_count(key)
    district_cache_contents[key] if district_cache_contents && district_cache_contents[key]
  end

  def district_cache_contents
    @_district_cache_school_levels ||= begin
      @level_codes = decorated_district.cache_data["district_schools_summary"]["school counts by level code"] || {}
      @school_types = decorated_district.cache_data["district_schools_summary"]["school counts by type"] || {}
      {}.tap do |st|
        st["charter"] = @school_types["charter"] || 0
        st["public"] = @school_types["public"] || 0
        st["preschool"] = @level_codes["p"] || 0
        st["elementary"] = @level_codes["e"] || 0
        st["middle"] = @level_codes["m"] || 0
        st["high"] = @level_codes["h"] || 0
        st["all"] = district_record.num_schools
      end
    end
  end

  def decorated_district
    @_decorated_district ||= DistrictCache.cached_results_for([district_record], CACHE_KEYS_FOR_READER).decorate_districts([district_record]).first
  end

  # StructuredMarkup
  def prepare_json_ld
    breadcrumbs.each { |bc| add_json_ld_breadcrumb(bc) }
  end

  def redirect_unless_valid_district
    redirect_to(city_path(state: state_name, city: city&.downcase), status: 301) unless district_record
  end

  def default_extras
    %w(summary_rating enrollment review_summary students_per_teacher)
  end

end
