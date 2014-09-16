class SchoolCacheQuery

  def initialize
    @cache_keys = []
    @school_ids_per_state = {}
  end

  def include_cache_keys(cache_keys)
    @cache_keys += Array.wrap(cache_keys)
    @cache_keys.uniq
    self
  end

  def include_schools(state, ids)
    school_ids_for_state = @school_ids_per_state[state] || []
    school_ids_for_state += Array.wrap(ids)
    @school_ids_per_state[state] = school_ids_for_state
    @school_ids_per_state
    self
  end

  def matching_schools_clause
    arel = SchoolCache.arel_table
    q ||= arel.grouping(false: true) # false = true in query prevents needing to special-case code below
    @school_ids_per_state.each_pair do |state, school_ids_for_state|
      q = q.or(
        q.grouping(
          arel[:state].eq(state).
          and(
            arel[:school_id].in(school_ids_for_state)
          )
        )
      )
    end
    q.to_sql
  end

  def query
    SchoolCache.where(matching_schools_clause)
  end

end