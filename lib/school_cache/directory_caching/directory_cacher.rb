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
    %w(county district_id city fax id lat level_code lon name nces_code phone state state_id street type zipcode)
  end

  def school_special_keys
    %w(url level district_name school_summary description home_page_url FIPScounty subtype)
  end

  def build_hash_for_cache
    return unless school.active?
    school.extend(GradeLevelConcerns)

    cache_hash = school_directory_keys.each_with_object({}) do |key, hash|
      hash[key] = [{ school_value: school.send(key) }]  # the array wrap is for consistency
    end
    validate!(cache_hash)

    special_cache_hash = school_special_keys.each_with_object({}) do |key, hash|
      if key == 'level'
        hash[key] = [{ school_value: school.process_level}]
      elsif key == 'url'
        hash[key] = [{ school_value: school_build_url }]
      elsif key == 'district_name'
        hash[key] = [{ school_value: district_name }]
      elsif key == 'description'
        hash[key] = [{ school_value: description }]
      elsif key == 'school_summary'
        hash[key] = [{ school_value: school_summary }]
      elsif key == 'home_page_url'
        hash[key] = [{ school_value: home_page_url }]
      elsif key == 'FIPScounty'
        hash[key] = [{ school_value: fipscounty }]
      elsif key == 'subtype'
        hash[key] = [{ school_value: subtype }]
      end
    end
    validate!(special_cache_hash)
    cache_hash.merge!(special_cache_hash)
  end

  def fipscounty
    school.FIPScounty.to_s.rjust(5, '0') if school.FIPScounty.present?
  end

  def school_build_url
    school_params = school_params(school)
    school_params.reject { | r,v | v.present? }.blank? && school_params.length == 4 ? URL_PREFIX + school_path(school_params) + '/' : ''
  end

  def district_name
    district = district_obj
    district.first.name if district && district.first
  end

  def district_obj
    @_district_obj ||= District.find_by_state_and_ids(school.state, school.district_id)
  end

  def home_page_url
    prepend_http(school.home_page_url) if school.home_page_url.present?
  end

  def description
    "\nIn-depth school information including test scores and student stats for\n#{school.name},\n#{school.city},\n#{school.state}.\n"
  end

  def subtype
    school.subtype.gsub 'yr_round', 'year_round' if school.subtype.present?
  end

  def school_summary
    rating = school.great_schools_rating
    (1..10).cover?(rating.to_i) ? school_summary_rated(rating) : school_summary_not_rated
  end

  def district_url(district)
    district_params = district_params_from_district(district)
    district_params.reject { | r,v | v.present? }.blank? ? (URL_PREFIX + city_district_path(district_params) + '/') : ''
  end

  def district_url_link
    if district_obj && district_obj.first
      " in the <a href='#{district_url(district_obj.first)}'>#{district_name}</a>"
    else
      ''
    end
  end

  def school_summary_not_rated
    "#{school.name}, a #{school.type} school located in #{school.city}, #{school.state}, serves grades #{school.process_level}#{district_url_link}."
  end

  def school_summary_rated(rating)
    str = "#{school.name}, a #{school.type} school located in #{school.city}, #{school.state}, serves grades #{school.process_level}#{district_url_link}."
    str + "It has received a GreatSchools Rating of #{rating} out of 10, based on a variety of school quality measures."
  end

  def self.active?
    true
  end

end
