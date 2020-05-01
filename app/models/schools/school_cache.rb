class SchoolCache < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'school_cache'
  attr_accessible :name, :school_id, :state, :value, :updated

  ETHNICITY = :Ethnicity
  ENROLLMENT = :Enrollment

  KEYS = %i(metrics esp_responses nearby_schools ratings reviews_snapshot feed_test_scores directory feed_metrics courses test_scores_gsdata)

  def self.for_school(name, school_id, state)
    SchoolCache.where(name: name, school_id: school_id, state: state).first()
  end

  def self.on_rw_db(&block)
    on_db(:gs_schooldb_rw, &block)
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

  def self.cached_results_for(schools, keys)
    query = SchoolCacheQuery.new.include_cache_keys(keys)
    [*schools].each do |school|
      query.include_schools(school.state, school.id)
    end
    SchoolCacheResults.new(keys, query.query_and_use_cache_keys)
  end

  self::KEYS.each do |key|
    method_name = "cached_#{key}_data"
    define_singleton_method(method_name) do |school|
      cache_key = "#{method_name}"
      if school.instance_variable_get("@#{cache_key}")
        return school.instance_variable_get("@#{cache_key}")
      end
      cached_data = if (school_cache = self.for_school(key,school.id,school.state))
                      school_cache.cache_data(symbolize_names: true)
                    else
                      {}
                    end
      school.instance_variable_set("@#{cache_key}", cached_data)
    end
  end

  def cache_data(options = {})
    JSON.parse(value, options) rescue {}
  end
end
