# class StateCacheQuery
#
#   def initialize
#     @cache_keys = []
#   end
#
#   def include_objects(objects)
#     objects = Array.wrap(objects)
#     objects_by_state = objects.group_by(&:state)
#     objects_by_state.each_pair do |state, objects_for_state|
#       include_districts(state, objects_for_state.map(&:id))
#     end
#     self
#   end
#
#   def include_cache_keys(cache_keys)
#     @cache_keys += Array.wrap(cache_keys)
#     @cache_keys.uniq
#     self
#   end
#
#   def matching_state_clause
#     arel = StateCache.arel_table
#     q ||= Arel::Nodes::Grouping.new(Arel::Nodes::SqlLiteral.new('false = true')) # false = true prevents needing to special-case code below
#     @district_ids_per_state.each_pair do |state, district_ids_for_state|
#       q = q.or(
#           q.grouping(
#               arel[:state].eq(state)
#           )
#       )
#     end
#     q.to_sql
#   end
#
#   def query
#     StateCache.where(matching_state_clause)
#   end
#
#   def query_and_use_cache_keys
#     StateCache.where(matching_state_clause).where(name: @cache_keys)
#   end
#
# end
