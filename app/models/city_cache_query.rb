# frozen_string_literal: true

class CityCacheQuery

  def initialize
    @cache_keys = []
    @city_ids = []
  end

  def self.decorate_cities(cities, *cache_names)
    query = self.new
                .include_cache_keys(cache_names)
                .include_objects(cities)
    query_results = query.query
    city_cache_results = CityCacheResults.new(cache_names, query_results)
    city_cache_results.decorate_cities(cities)
  end

  def self.for_city(city)
    raise ArgumentError.new('City must not be nil') if city.nil?
    new.include_city_ids(city.id)
  end

  def include_objects(objects)
    include_city_ids(objects.map(&:id))
    self
  end

  def include_cache_keys(cache_keys)
    @cache_keys += Array.wrap(cache_keys)
    @cache_keys.uniq!
    self
  end

  def include_city_ids(ids)
    @city_ids += Array.wrap(ids)
    self
  end

  def matching_cities_clause
    {city_id: @city_ids}
  end

  def query
    CityCache.where(matching_cities_clause).where(name: @cache_keys)
  end
end
