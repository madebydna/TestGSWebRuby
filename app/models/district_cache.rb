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

  # def self.for_districts_keys(keys, districts, state)
  #   district_data = Hash.new { |h,k| h[k] = {} }
  #   cached_data = DistrictCache.where(name: keys, district_id: districts, state: state)
  #   cached_data.each do |cache|
  #     cache_value = begin JSON.parse(cache.value) rescue {} end
  #     district_data[cache.district_id].merge! cache.name => cache_value
  #   end
  #   district_data
  # end

  #look for one district cache record
  #look for many district cache record
  # ! for_districts && for_keys

  def self.cached_results_for(districts, keys)
    query = DistrictCache.include_cache_keys(keys).for_districts(districts)
    DistrictCacheResults.new(keys, query)
  end

  # self::KEYS.each do |key|
  #   method_name = "cached_#{key}_data"
  #   define_singleton_method(method_name) do |district|
  #     cache_key = "#{method_name}"
  #     if district.instance_variable_get("@#{cache_key}")
  #       return district.instance_variable_get("@#{cache_key}")
  #     end
  #     cached_data = if (district_cache = self.for_district(district).include_cache_keys(key))
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
