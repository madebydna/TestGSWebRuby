# frozen_string_literal: true

module DistrictCaching
  class DistrictContentCacher < CityCacher
    include GradeLevelConcerns

    CACHE_KEY = 'district_content'

    def self.listens_to?(data_type)
      data_type == :district_content
    end

    def header_keys
      %w(id name school_count city levels)
    end

    def build_hash_for_cache
      districts.map do |district|
        hash = {}
        hash['name'] = [{ city_value: district.name }]
        hash['school_count'] = [{ city_value: district.num_schools }]
        hash['id'] = [{ city_value: district.id }]
        hash['levels'] = [{ city_value: GradeLevelConcerns.human_readable_level(district.level) }]
        hash['city'] = [{ city_value: district.city }]
        hash
      end
    end

    def districts
      # district_ids = city.schools_within_city.uniq {|s| s[:district_id] }.map{|s| s[:district_id]}.reject {|x| x == 0}
      # District.find_by_state_and_ids(city.state, district_ids).active.where(charter_only: 0)
      District.find_by_state_and_city(city.state, city.name).not_charter_only
    end

  end
end