class StateCache < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'state_cache'
  attr_accessible :name, :state, :value, :updated

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

  def cache_data(options = {})
    JSON.parse(value, options) rescue {}
  end
end
