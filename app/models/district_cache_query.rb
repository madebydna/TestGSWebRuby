class DistrictCacheQuery

  def initialize
    @cache_keys = []
    @district_ids_per_state = {}
  end

  def include_cache_keys(cache_keys)
    @cache_keys += Array.wrap(cache_keys)
    @cache_keys.uniq
    self
  end

  def include_districts(state, ids)
    district_ids_for_state = @district_ids_per_state[state] || []
    district_ids_for_state += Array.wrap(ids)
    @district_ids_per_state[state] =district_ids_for_state
    @district_ids_per_state
    self
  end

  def matching_districts_clause
    arel = DistrictCache.arel_table
    q ||= arel.grouping(false: true) # false = true in query prevents needing to special-case code below
    @district_ids_per_state.each_pair do |state, district_ids_for_state|
      q = q.or(
        q.grouping(
          arel[:state].eq(state).
          and(
            arel[:district_id].in(district_ids_for_state)
          )
        )
      )
    end
    q.to_sql
  end

  def query
    DistrictCache.where(matching_districts_clause)
  end

  def query_and_use_cache_keys
    DistrictCache.where(matching_districts_clause).where(name: @cache_keys)
  end

end