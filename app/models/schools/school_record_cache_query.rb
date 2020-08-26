class SchoolRecordCacheQuery < SchoolCacheQuery
  def self.decorate_schools(schools, *cache_names)
    query = self.new
      .include_cache_keys(cache_names)
      .include_objects(schools)
    query_results = query.query_and_use_cache_keys
    school_cache_results = SchoolRecordCacheResults.new(cache_names, query_results)
    school_cache_results.decorate_schools(schools)
  end

  def self.for_school(school)
    raise ArgumentError.new('School must not be nil') if school.nil?
    new.tap do |cache_query|
      cache_query.include_schools(school.state, school.school_id)
    end
  end

  def include_objects(objects)
    objects_by_state = objects.group_by(&:state)
    objects_by_state.each_pair do |state, objects_for_state|
      include_schools(state, objects_for_state.map(&:school_id))
    end
    self
  end
end