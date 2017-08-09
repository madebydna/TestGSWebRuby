class DistrictDirectoryCacher < DistrictCacher
  include DistrictCacheValidation

  CACHE_KEY = 'district_directory'

  def self.listens_to?(data_type)
    :district_directory == data_type
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

  def district_directory_keys
    %w(county id city fax FIPScounty lat level level_code lon name nces_code phone state state_id street home_page_url zipcode)
  end

  def build_hash_for_cache
    cache_hash = district_directory_keys.each_with_object({}) do |key, hash|
      hash[key] = [{ district_value: district.send(key) }] # the array wrap is for consistency
    end
    validate!(cache_hash)
  end

end