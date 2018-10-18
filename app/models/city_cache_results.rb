# frozen_string_literal: true

class CityCacheResults
  def initialize(cache_keys, query_results)
    @cache_keys = Array.wrap(cache_keys)
    @query_results = query_results
  end

  def decorate_cities(cities)
    Array.wrap(cities).map do |city|
      CityCacheDecorator.new(city, city_data[city.id] || {})
    end
  end

  def decorate_city(city)
    decorate_cities(city).first
  end

  private

  def city_data
    @_city_data ||= begin
      @query_results.each_with_object({}) do |result, city_data_hash|
        city_id = result[:city_id]
        cache_key = result[:name]
        cache_value = begin
          Oj.load(result.value) rescue {}
        end

        city_data_hash[city_id] ||= {}
        city_data_hash[city_id][cache_key] = cache_value
      end
    end
  end
end