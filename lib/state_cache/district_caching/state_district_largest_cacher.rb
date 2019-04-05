# frozen_string_literal: true

class StateDistrictLargestCacher < StateCacher
  include GradeLevelConcerns
  # include DistrictCachedCharacteristicsMethods

  CACHE_KEY = 'district_largest'

  def build_hash_for_cache
    district_ids.map do |district_id|
      district = District.find_by_state_and_ids(state, district_id)
      district.enrollment # maybe???
      {}.tap do |hash|
        hash['name'] = [{ city_value: district.name }]
        hash['school_count'] = [{ city_value: district.num_schools }]
        hash['id'] = [{ city_value: district.id }]
        hash['lat'] = [{ city_value: district.lat }]
        hash['lon'] = [{ city_value: district.lon }]
        hash['levels'] = [{ city_value: GradeLevelConcerns.human_readable_level(district.level) }]
        hash['city'] = [{ city_value: district.city }]
        hash['zip'] = [{ city_value: district.zipcode }]
      end
    end
  end

  def district_ids
    district_ids = District.ids_by_state(state)
    dc_sorted_ids = district_ids.sort do |dc_id1, dc_id2|
      dc1 = district_characteristics(dc_id1, state)
      d1 = enrollment_all_students(dc1)
      dc2 = district_characteristics(dc_id2, state)
      d2 = enrollment_all_students(dc2)
      district_enrollment_value(d1) <=> district_enrollment_value(d2)
    end
    dc_sorted_ids.slice(0,4) # fix this
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