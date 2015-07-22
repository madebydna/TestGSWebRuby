class SchoolCache < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'school_cache'
  attr_accessible :name, :school_id, :state, :value, :updated

  KEYS = [:characteristics, :esp_responses, :nearby_schools, :progress_bar, :ratings, :reviews_snapshot, :test_scores]

  def self.for_school(name, school_id, state)
    SchoolCache.where(name: name, school_id: school_id, state: state).first()
  end

  def self.for_schools_keys(keys, school_ids, state)
    school_data = Hash.new { |h,k| h[k] = {} }
    cached_data = SchoolCache.where(name: keys, school_id: school_ids, state: state)
    cached_data.each do |cache|
      cache_value = begin JSON.parse(cache.value) rescue {} end
      school_data[cache.school_id].merge! cache.name => cache_value
    end
    school_data
  end

  self::KEYS.each do |key|
    method_name = "cached_#{key}_data"
    define_singleton_method(method_name) do |school|
      cache_key = "#{method_name}#{school.state}#{school.id}"
      return instance_variable_get("@#{cache_key}") if instance_variable_get("@#{cache_key}")
      cached_data = self.for_school(key,school.id,school.state).cache_data(symbolize_names: true)
      instance_variable_set("@#{cache_key}", cached_data)
    end
  end

  def cache_data(options = {})
    JSON.parse(value, options) rescue {}
  end
end
