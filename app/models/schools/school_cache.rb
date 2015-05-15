class SchoolCache < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'school_cache'
  attr_accessible :name, :school_id, :state, :value, :updated

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

  def cache_data
    JSON.parse(value) rescue {}
  end
end
