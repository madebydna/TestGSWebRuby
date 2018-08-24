# frozen_string_literal: true

module LevelCaching
  class CityLevelCacher < CityCacher

    CACHE_KEY = 'school_levels'

    def self.listens_to?(data_type)
       data_type == :school_levels
    end

    def level_keys
      %w(all preschool elementary middle high public charter private)
    end

    def build_hash_for_cache
      level_keys.each_with_object({}) do |key, hash|
        if key == 'all'
          hash[key] = [{ city_value: all_schools }]
        elsif key == 'preschool'
          hash[key] = [{ city_value: preschools }]
        elsif key == 'elementary'
          hash[key] = [{ city_value: elementary_schools }]
        elsif key == 'middle'
          hash[key] = [{ city_value: middle_schools }]
        elsif key == 'high'
          hash[key] = [{ city_value: high_schools }]
        elsif key == 'public'
          hash[key] = [{ city_value: public_schools }]
        elsif key == 'charter'
          hash[key] = [{ city_value: charter_schools }]
        elsif key == 'private'
          hash[key] = [{ city_value: private_schools }]
        end
      end
    end

    def all_schools
      city.schools_within_city.count
    end

    def preschools
      city.schools_within_city.select {| school | school.includes_preschool?}.count
    end

    def elementary_schools
      city.schools_within_city.select {| school | school.includes_elementaryschool?}.count
    end

    def middle_schools
      city.schools_within_city.select {| school | school.includes_middleschool?}.count
    end

    def high_schools
      city.schools_within_city.select {| school | school.includes_highschool?}.count
    end

    def public_schools
      city.schools_within_city.select {| school | school.includes_public?}.count
    end

    def charter_schools
      city.schools_within_city.select {| school | school.includes_charter?}.count
    end

    def private_schools
      city.schools_within_city.select {| school | school.private_school?}.count
    end

  end
end
