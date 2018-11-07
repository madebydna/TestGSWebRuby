# frozen_string_literal: true

class CityCacheDecorator
  attr_reader :city, :cache_data

  def initialize(city, cache_data = {})
    @city = city
    @cache_data = cache_data
  end

  def self.for_city_and_keys(city, *keys)
    query_results = CityCacheQuery.for_city(city).include_cache_keys(keys).query
    CityCacheResults.new(keys, query_results).decorate_city(city)
  end

  def method_missing(meth, *args)
    if @city.respond_to?(meth)
      @city.send(meth, *args)
    else
      super
    end
  end

  def respond_to?(meth)
    @city.respond_to?(meth)
  end

  def respond_to_missing?(meth, include_private=false)
    @city.respond_to_missing?(meth, include_private)
  end
end
