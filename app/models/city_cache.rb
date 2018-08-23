# frozen_string_literal: true

class CityCache < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'city_cache'
  attr_accessible :name, :city_id, :value, :updated
  KEYS = %i(header school_levels)


  def self.for_city_and_name(name, city_id)
    CityCache.where(name: name, city_id: city_id).first
  end

  def self.for_city(city_id)
    CityCache.where(city_id: city_id)
  end

  self::KEYS.each do |key|
    method_name = "cached_#{key}_data"
    define_singleton_method(method_name) do |city|
      cache_key = "#{method_name}"
      if city.instance_variable_get("@#{cache_key}")
        return city.instance_variable_get("@#{cache_key}")
      end
      cached_data = if (city_cache = self.for_city_and_name(key,city.city_id))
                      city_cache.cache_data(symbolize_names: true)
                    else
                      {}
                    end
      city.instance_variable_set("@#{cache_key}", cached_data)
    end
  end

  def cache_data(options = {})
    JSON.parse(value, options) rescue {}
  end
end
