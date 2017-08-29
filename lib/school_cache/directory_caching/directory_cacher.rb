class DirectoryCaching::DirectoryCacher < Cacher
  include CacheValidation
  include UrlHelper
  include Rails.application.routes.url_helpers

  URL_PREFIX = 'https://www.greatschools.org'

  CACHE_KEY = 'directory'

  def self.listens_to?(data_type)
    :directory == data_type
  end

  def school_directory_keys
    %w(county district_id city fax FIPScounty id lat level_code lon name nces_code phone state state_id street subtype type home_page_url zipcode)
  end

  def school_special_keys
    %w(url level district_name school_summary)
  end

  def build_hash_for_cache
    school.extend(GradeLevelConcerns)

    cache_hash = school_directory_keys.each_with_object({}) do |key, hash|
      hash[key] = [{ school_value: school.send(key) }] # the array wrap is for consistency
    end
    validate!(cache_hash)

    special_cache_hash = school_special_keys.each_with_object({}) do |key, hash|
      if key == 'level'
        hash[key] = [{ school_value: school.process_level}]
      elsif key == 'url'
        hash[key] = [{ school_value: school_build_url }]
      elsif key == 'district_name'
        hash[key] = [{ school_value: district_name }]
      elsif key == 'school_summary'
        hash[key] = [{ school_value: school_summary }]
      end
    end
    validate!(special_cache_hash)

    cache_hash.merge!(special_cache_hash)
  end

  def school_build_url
    school_params = school_params(school)
    URL_PREFIX + school_path(school_params) + '/'
  end

  def district_name
    district = District.find_by_state_and_ids(school.state, school.id)
    district.first.name if district && district.first
  end

  def school_summary
    # not sure what to do with this one.
    ''
  end

  def self.active?
    ENV_GLOBAL['is_feed_builder'].present? && [true, 'true'].include?(ENV_GLOBAL['is_feed_builder'])
  end

end
