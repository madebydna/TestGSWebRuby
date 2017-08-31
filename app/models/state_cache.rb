class StateCache < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'state_cache'
  attr_accessible :name, :state, :value, :updated
  KEYS = [:state_characteristics]

  def self.for_state(name, state)
    StateCache.where(name: name, state: state).first
  end

  def self.for_state_keys(keys, state)
    state_data = Hash.new { |h,k| h[k] = {} }
    cached_data = StateCache.where(name: keys, state: state)
    cached_data.each do |cache|
      cache_value = begin JSON.parse(cache.value) rescue {} end
      state_data[cache.state].merge! cache.name => cache_value
    end
    state_data
  end

  # def self.cached_results_for(districts, keys)
  #   query = StateCacheQuery.new.include_cache_keys(keys)
  #   [*districts].each do |district|
  #     query.include_districts(district.state, district.id)
  #   end
  #   DistrictCacheResults.new(keys, query.query_and_use_cache_keys)
  # end
  #
  # self::KEYS.each do |key|
  #   method_name = "cached_#{key}_data"
  #   define_singleton_method(method_name) do |district|
  #     cache_key = "#{method_name}"
  #     if district.instance_variable_get("@#{cache_key}")
  #       return district.instance_variable_get("@#{cache_key}")
  #     end
  #     cached_data = if (district_cache = self.for_district(key,district.id,district.state))
  #                     district_cache.cache_data(symbolize_names: true)
  #                   else
  #                     {}
  #                   end
  #     district.instance_variable_set("@#{cache_key}", cached_data)
  #   end
  # end

  def cache_data(options = {})
    JSON.parse(value, options) rescue {}
  end
end
