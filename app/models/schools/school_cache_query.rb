class SchoolCacheQuery

  def initialize
    @cache_keys = []
    @school_ids_per_state = {}
  end

  def self.for_school(school)
    raise ArgumentError.new('School must not be nil') if school.nil?
    new.tap do |cache_query|
      cache_query.include_schools(school.state, school.id)
    end
  end

  def include_school_objects(schools)
    schools = Array.wrap(schools)
    schools_by_state = schools.group_by(&:state)
    schools_by_state.each_pair do |state, schools_for_state|
      include_schools(state, schools_for_state.map(&:id))
    end
    self
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
    q ||= Arel::Nodes::Grouping.new(Arel::Nodes::SqlLiteral.new('false = true')) # false = true prevents needing to special-case code below
    @school_ids_per_state.each_pair do |state, school_ids_for_state|
      next if school_ids_for_state.blank?
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

  def query_and_use_cache_keys
    SchoolCache.where(matching_schools_clause).where(name: @cache_keys)
  end

end
