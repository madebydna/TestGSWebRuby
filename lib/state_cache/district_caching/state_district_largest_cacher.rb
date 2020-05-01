# frozen_string_literal: true

class StateDistrictLargestCacher < StateCacher
  CACHE_KEY = 'district_largest'

  def build_hash_for_cache
    district_ids.map do |district_id|
      district = District.find_by_state_and_ids(state, district_id).first
      {}.tap do |hash|
        hash['name'] = district.name
        hash['id'] = district.id
        hash['enrollment'] = overall_enrollment(district_id)
        hash['city'] = district.city
        hash['state'] = district.state
        hash['levels'] = GradeLevelConcerns.human_readable_level(district.level)
        hash['school_count'] = district.num_schools
      end
    end
  end

  def district_ids
    district_ids = District.ids_by_state(state)
    dc_sorted_ids = district_ids.sort_by(&method(:overall_enrollment))
    dc_sorted_ids.length >= 5 ? dc_sorted_ids[-5..-1].reverse : dc_sorted_ids.reverse
  end

  # TODO: this method does not handle nil cache
  def enrollment_all_students(metrics_cache)
    JSON.parse(metrics_cache).fetch('Enrollment',[{}]).compact.select {|hash| hash['breakdown'] == 'All students' && hash['grade'] == 'All'} if metrics_cache
  end

  def metrics(district_id)
    DistrictCache.find_by(district_id: district_id, state: @state, name: 'metrics')&.value
  end

  # rubocop:disable Lint/SafeNavigationChain
  def district_enrollment_value(district_metrics_results)
    district_metrics_results&.first.present? ? district_metrics_results&.first['district_value'].to_i : 0
  end
  # rubocop:enable Lint/SafeNavigationChain
end

def overall_enrollment(district_id)
  @_overall_enrollment ||= Hash.new do |h, id|
    h[id] = district_enrollment_value(enrollment_all_students(metrics(id)))
  end
  @_overall_enrollment[district_id]
end
