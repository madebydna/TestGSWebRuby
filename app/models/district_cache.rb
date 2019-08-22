class DistrictCache < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'district_cache'
  attr_accessible :name, :district_id, :state, :value, :updated
  KEYS = [:test_scores, :directory_census, :district_directory, :feed_district_characteristics]

  def self.for_district(district)
    where(state: district.state, district_id: district.id)
  end

  def self.include_cache_keys(keys)
    where(name: keys)
  end

  def self.for_districts(districts)
    state_hash = districts.group_by(&:state).tap do |hash|
      hash.each do |k, v|
        hash[k] = v.map(&:id)
      end  
    end
    matching_clause = state_hash.map do |state,ids|
      sanitize_sql_for_conditions(["(state = ? and district_id IN (?))", state, ids])
    end.join(" OR ")
    where(matching_clause)
  end

  # TODO: this should be moved to data reader
  def self.cached_results_for(districts, keys)
    query = DistrictCache.include_cache_keys(keys).for_districts(districts)
    DistrictCacheResults.new(keys, query)
  end

  def cache_data(options = {})
    JSON.parse(value, options) rescue {}
  end
end
