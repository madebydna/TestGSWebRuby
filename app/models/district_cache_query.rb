# frozen_string_literal: true

class DistrictCacheQuery

  def initialize
    @cache_keys = []
    @district_ids_per_state = {}
  end

  def include_objects(objects)
    objects = Array.wrap(objects)
    objects_by_state = objects.group_by(&:state)
    objects_by_state.each_pair do |state, objects_for_state|
      include_districts(state, objects_for_state.map(&:id))
    end
    self
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

  def self.for_district(district)
    raise ArgumentError.new('District must not be nil') if district.nil?
    new.tap do |cache_query|
      cache_query.include_districts(district.state, district.id)
    end
  end

  def matching_districts_clause
    arel = DistrictCache.arel_table
    q ||= Arel::Nodes::Grouping.new(Arel::Nodes::SqlLiteral.new('false = true')) # false = true prevents needing to special-case code below
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
