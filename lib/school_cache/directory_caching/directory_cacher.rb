class DirectoryCaching::DirectoryCacher < Cacher
  include CacheValidation

  CACHE_KEY = 'directory'

  def self.listens_to?(data_type)
    :directory == data_type
  end

  def school_directory_keys
    %w(county district_id city fax FIPScounty id lat level level_code lon name nces_code phone state state_id street subtype type home_page_url zipcode)
  end

  def build_hash_for_cache
    cache_hash = school_directory_keys.each_with_object({}) do |key, hash|
      hash[key] = [{ school_value: school.send(key) }] # the array wrap is for consistency
    end
    validate!(cache_hash)
    cache_hash.merge!(school_object_extra_fields)
  end

  def school_object_extra_fields

  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

end
