class DistrictDirectoryCacher < DistrictCacher
  include DistrictCacheValidation
  include UrlHelper
  include Rails.application.routes.url_helpers

  URL_PREFIX = 'https://www.greatschools.org'

  CACHE_KEY = 'district_directory'

  def self.listens_to?(data_type)
    :district_directory == data_type
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

  def district_directory_keys
    %w(county id city fax FIPScounty lat level_code lon name nces_code phone state state_id street home_page_url zipcode)
  end

  def district_special_keys
    %w(level url description_str)
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
        hash[key] = [{ district_value: description_str }]
      end
    end
    validate!(special_cache_hash)

    cache_hash.merge!(special_cache_hash)
  end

  def district_url
    district_params = district_params_from_district(district)
    URL_PREFIX + city_district_path(district_params) + '/'
  end

  def description_str
    'In-depth district information including test scores and student stats for\n' +
        district.name + '\n' +
        district.city + '\n' +
        district.state + '.'
  end

end