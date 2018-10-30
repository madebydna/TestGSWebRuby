# frozen_string_literal: true

module DistrictCaching
  class DistrictContentCacher < CityCacher
    include GradeLevelConcerns

    CACHE_KEY = 'district_content'

    def self.listens_to?(data_type)
      data_type == :district_content
    end

    def build_hash_for_cache
      districts.map do |district|
        {}.tap do |hash|
          hash['name'] = [{ city_value: district.name }]
          hash['school_count'] = [{ city_value: district.num_schools }]
          hash['id'] = [{ city_value: district.id }]
          hash['lat'] = [{ city_value: district.lat }]
          hash['lon'] = [{ city_value: district.lon }]
          hash['levels'] = [{ city_value: GradeLevelConcerns.human_readable_level(district.level) }]
          hash['city'] = [{ city_value: district.city }]
          hash['zip'] = [{ city_value: district.zipcode }]
        end
      end
    end

    def districts
      district_ids = city.schools_within_city.where.not(level: 'UG').map(&:district_id).uniq.reject(&:zero?)
      District.find_by_state_and_ids(city.state, district_ids).active.where(charter_only: 0)
    end

  end
end