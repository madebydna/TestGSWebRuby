class DistrictDirectoryCacher < DistrictCacher
  include DistrictCacheValidation
  include UrlHelper
  include Rails.application.routes.url_helpers

  URL_PREFIX = 'https://www.greatschools.org'

  CACHE_KEY = 'district_directory'

  def self.listens_to?(data_type)
    data_type == :district_directory || data_type == :directory
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

  def district_directory_keys
    %w(county id city fax lat level_code lon name nces_code phone state state_id street zipcode)
  end

  def district_special_keys
    %w(level url description home_page_url FIPScounty)
  end

  def build_hash_for_cache
    district.extend(GradeLevelConcerns)

    cache_hash = district_directory_keys.each_with_object({}) do |key, hash|
      hash[key] = [{ district_value: district.send(key) }] # the array wrap is for consistency
    end
    validate!(cache_hash)

    special_cache_hash = district_special_keys.each_with_object({}) do |key, hash|
      if key == 'level'
        hash[key] = [{ district_value: district.process_level }]
      elsif key == 'url'
        hash[key] = [{ district_value: district_url }]
      elsif key == 'description'
        hash[key] = [{ district_value: description }]
      elsif key == 'home_page_url'
        hash[key] = [{ district_value: home_page_url }]
      elsif key == 'FIPScounty'
        hash[key] = [{ district_value: fipscounty }]
      end
    end
    validate!(special_cache_hash)

    cache_hash.merge!(special_cache_hash)
  end

  def fipscounty
    district.FIPScounty.to_s.rjust(5, '0') if district.FIPScounty.present?
  end

  def district_url
    district_params = district_params_from_district(district)
    district_params.reject { | r,v | v.present? }.blank? ? (URL_PREFIX + city_district_path(district_params) + '/') : ''
  end

  def home_page_url
    prepend_http(district.home_page_url) if district.home_page_url.present?
  end

  def description
    "\nIn-depth district information including test scores and student stats for\n#{district.name},\n#{district.city},\n#{district.state}.\n"
  end

end