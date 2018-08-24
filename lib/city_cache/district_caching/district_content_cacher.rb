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
          header_keys.each_with_object({}) do |key, hash|
            if key == 'name'
              hash[key] = [{ city_value: district.name }]
            elsif key == 'school_count'
              hash[key] = [{ city_value: district.num_schools }]
            elsif key == 'id'
              hash[key] = [{ city_value: district.id }]
            elsif key == 'levels'
              hash[key] = [{ city_value: GradeLevelConcerns.human_readable_level(district.level) }]
            elsif key == 'city'
              hash[key] = [{ city_value: district.city }]
            end
          end
        end
    end

    # def generate_url(district)
    #   # district_url(district_params(district.state, district.city, district.name))
    #   city_district_url(district_params_from_district(district))
    # end

    def districts
      district_ids = city.schools_within_city.uniq {|s| s[:district_id] }.map{|s| s[:district_id]}.reject {|x| x == 0}
      District.find_by_state_and_ids(city.state, district_ids)
    end

  end
end