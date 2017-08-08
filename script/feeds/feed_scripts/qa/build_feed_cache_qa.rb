#!/usr/bin/env rails runner
require 'pp';
CACHE_KEYS = ['feed_test_scores', 'ratings']

class CacheKeyBuildQa
  attr_reader :cache_keys, :cache

  def initialize(cache, *cache_keys)
    @cache_keys = cache_keys
    @cache = cache
    CacheKeyBuildQa.define_cache_key_methods(cache_keys)
  end

  def results
    results = cache_keys.each_with_object({}) do |key, h|
      h["#{cache.to_s}:#{key}"] = key_results(key)
    end
    results
  end

  private

  def self.define_cache_key_methods(cache_keys)
    self.count_methods(cache_keys)
    self.max_updated_methods(cache_keys)
    self.min_updated_methods(cache_keys)
  end

  def self.count_methods(cache_keys)
    cache_keys.each do |key|
      define_method("#{key}_count") do
        @cache.where({name: key}).count
      end
    end
  end

  def self.max_updated_methods(cache_keys)
    cache_keys.each do |key|
      define_method("#{key}_max_updated") do
        @cache.where({name: key}).maximum('updated')
      end
    end
  end

  def self.min_updated_methods(cache_keys)
    cache_keys.each do |key|
      define_method("#{key}_min_updated") do
        @cache.where({name: key}).minimum('updated')
      end
    end
  end

  def key_results(key)
    {
      count: send("#{key}_count".to_sym),
      min_updated: send("#{key}_min_updated".to_sym),
      max_updated: send("#{key}_max_updated".to_sym)
    }
  end
end

school_cache_qa = CacheKeyBuildQa.new(SchoolCache, *CACHE_KEYS)
district_cache_qa = CacheKeyBuildQa.new(DistrictCache, *CACHE_KEYS)

pp school_cache_qa.results
pp district_cache_qa.results
