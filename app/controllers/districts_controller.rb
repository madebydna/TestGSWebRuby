class DistrictsController < ApplicationController
  include CommunityParams
  include AdvertisingAndPageAnalyticsConcerns
  include CommunityConcerns

  CACHE_KEYS_FOR_READER = ['district_schools_summary', 'district_characteristics']

  layout 'application'
  before_filter :redirect_unless_valid_district

  def show
    @locality = locality
    @school_levels = school_levels
    @breadcrumbs = breadcrumbs
    @serialized_schools = serialized_schools
    @hero_stats = hero_stats
    @hero_narration =  build_header_narration
    set_district_meta_tags
    set_ad_targeting_props
    set_page_analytics_data
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
    largest_district_id = city_key_value(:id)
    largest_district_id == district_record.id
  end


  ###################################################################################################################
  ######## NEED TO COMBINE WITH CITY FUNCTIONS
  def district_content_field(district_content, key)
    district_content[key].first['city_value'] if district_content && district_content[key]
  end

  def district_enrollment_dc(district_id)
    dc = DistrictCache.where(name: 'district_characteristics', district_id: district_id, state: state)
    dc_hash = JSON.parse(dc.first.value) if dc.present? && dc.first
    dc_hash['Enrollment'].first['district_value'].to_i if dc_hash && dc_hash['Enrollment'] && dc_hash['Enrollment'].first
  end

  def district_content
    @_district_content ||= begin
      if city_cache_district_content.present?
        dc = city_cache_district_content.map do |district_content|
          {}.tap do |d|
            name = district_content_field(district_content, 'name')
            city = district_content_field(district_content, 'city')
            d[:id] = district_content_field(district_content, 'id')
            d[:districtName] = name
            d[:grades] = district_content_field(district_content, 'levels')
            d[:numSchools] = district_content_field(district_content, 'school_count')
            d[:url] = district_url(district_params(state, city, name))
            d[:enrollment] =  district_enrollment_dc(district_content_field(district_content, 'id'))
            d[:zip] = district_content_field(district_content, 'zip')
          end
        end
        dc.sort_by { |h| h[:enrollment] ? h[:enrollment] : 0 }.reverse!
      else
        []
      end
    end
  end

  def city_cache_district_content
    @_city_cache_district_content ||= begin
      cc = CityCache.for_name_and_city_id('district_content', district_record.city_record.id)
      JSON.parse(cc.value) if cc.present?
    end
  end
###############################################################################################################################

# rubocop:disable Lint/SafeNavigationChain
  def city_key_value(key)
    district_content&.first[key]
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
        cp[:stateLong] = state_name.gs_capitalize_words
        cp[:stateShort] = state.upcase
        cp[:searchResultBrowseUrl] = search_district_browse_path(
          state: gs_legacy_url_encode(States.state_name(state)),
          city: gs_legacy_url_encode(city),
          district_name: gs_legacy_url_encode(district),
          trailing_slash: true
        )
        cp[:zipCode] = district_record.mail_zipcode[0..4]
        cp[:phone] = district_record.phone if district_record.phone.present?
        cp[:districtUrl] = prepend_http district_record.home_page_url if district_record.home_page_url.present?
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
    @_district_enrollment ||= decorated_district.enrollment
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
