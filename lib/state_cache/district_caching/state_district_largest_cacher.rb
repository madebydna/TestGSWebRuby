# frozen_string_literal: true

class StateDistrictLargestCacher < StateCacher
  include GradeLevelConcerns
  include CommunityConcerns

  CACHE_KEY = 'district_largest'

  def build_hash_for_cache
    district_ids.map do |district_id|
      district = District.find_by_state_and_ids(state, district_id).first
      {}.tap do |hash|
        hash['name'] = district.name 
        hash['id'] = district.id 
        hash['enrollment'] = district_enrollment_cache(district_id)
        hash['city'] = district.city 
        hash['state'] = district.state 
        hash['levels'] = GradeLevelConcerns.human_readable_level(district.level)
        hash['school_count'] = district.num_schools
      end
    end
  end

  # AC_TODO: Refactor this to use district_enrollment_cache method to retrieve enrollment values
  def district_ids
    district_ids = District.ids_by_state(state)
    dc_sorted_ids = district_ids.sort do |dc_id1, dc_id2|
      dc1 = district_characteristics(dc_id1, state)
      d1 = enrollment_all_students(dc1)
      dc2 = district_characteristics(dc_id2, state)
      d2 = enrollment_all_students(dc2)
      district_enrollment_value(d1) <=> district_enrollment_value(d2)
    end
    dc_sorted_ids.length >= 5 ? dc_sorted_ids[-5..-1].reverse : dc_sorted_ids.reverse 
  end

  def enrollment_all_students(district_characteristics_cache)
    JSON.parse(district_characteristics_cache).fetch('Enrollment',[{}]).compact.select {|hash| hash['breakdown'] == 'All students' && hash['grade'].nil?} if district_characteristics_cache
  end

  def district_characteristics(district_id, state)
    DistrictCache.for_district('district_characteristics', district_id, state )&.value
  end
  # rubocop:disable Lint/SafeNavigationChain
  def district_enrollment_value(district_characteristics_results)
    district_characteristics_results&.first.present? ? district_characteristics_results&.first['district_value'].to_i : 0
  end
  # rubocop:enable Lint/SafeNavigationChain
end