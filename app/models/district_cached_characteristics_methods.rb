# frozen_string_literal: true

module DistrictCachedCharacteristicsMethods
  FOUR_YEAR_GRADE_RATE = '4-year high school graduation rate'
  UC_CSU_ENTRANCE = 'Percent of students who meet UC/CSU entrance requirements'
  SAT_SCORE = 'Average SAT score'
  SAT_PARTICIPATION = 'SAT percent participation'
  SAT_PERCENT_COLLEGE_READY = 'SAT percent college ready'
  ACT_SCORE = 'Average ACT score'
  ACT_PARTICIPATION = 'ACT participation'
  ACT_PERCENT_COLLEGE_READY = 'ACT percent college ready'
  AP_ENROLLED = 'Percentage AP enrolled grades 9-12'
  AP_EXAMS_PASSED = 'Percentage of students passing 1 or more AP exams grades 9-12'
  ACT_SAT_PARTICIPATION = 'Percentage SAT/ACT participation grades 11-12'
  ACT_SAT_PARTICIPATION_9_12 = 'Percent of Students who Participated in the SAT/ACT in grades 9-12'

  def district_characteristics
    cache_data.fetch('district_characteristics', {})
  end

  def enrollment
    enrollment_data = district_characteristics.fetch('Enrollment', [{}])
    max_year(having_district_value(all_students(enrollment_data)))['district_value']
  end

  def ethnicity_data
    ethnicity_data = district_characteristics.fetch('Ethnicity', [{}])
    having_district_value(except_all_students(ethnicity_data))
  end

  def act_participation
    district_characteristics.fetch(ACT_PARTICIPATION, [{}])
  end

  def high_school_graduation_rate
    district_characteristics.fetch(FOUR_YEAR_GRADE_RATE, [{}])
  end

  def uc_csu_entrance_requirements
    district_characteristics.fetch(UC_CSU_ENTRANCE, [{}])
  end

  def average_act_score
    district_characteristics.fetch(ACT_SCORE, [{}])
  end

  def act_percent_college_ready
    district_characteristics.fetch(ACT_PERCENT_COLLEGE_READY, [{}])
  end

  def sat_percent_college_ready
    district_characteristics.fetch(SAT_PERCENT_COLLEGE_READY, [{}])
  end

  def ap_exams_passed
    district_characteristics.fetch(AP_EXAMS_PASSED, [{}])
  end

  def except_all_students(array_of_hashes)
    array_of_hashes.compact.reject {|hash| hash['breakdown'] == 'All students'}
  end

  def college_readiness_hash
    {}.tap do |h|
      h[ACT_PARTICIPATION] = act_participation if act_participation
      h[FOUR_YEAR_GRADE_RATE] = high_school_graduation_rate if high_school_graduation_rate
      h[UC_CSU_ENTRANCE] = uc_csu_entrance_requirements if uc_csu_entrance_requirements
      h[ACT_SCORE] = average_act_score if average_act_score
      h[ACT_PERCENT_COLLEGE_READY] = act_percent_college_ready if act_percent_college_ready
      h[SAT_PERCENT_COLLEGE_READY] = sat_percent_college_ready if sat_percent_college_ready
      h[AP_EXAMS_PASSED] = ap_exams_passed if ap_exams_passed
    end
  end

  def all_students(array_of_hashes)
    with_all_students_breakdown = array_of_hashes.compact.select {|hash| hash['breakdown'] == 'All students'}
    if with_all_students_breakdown.length > 1
      GSLogger.warn(:misc, nil, message: 'District characteristics cacher: multiple values with All students breakdown', vars: {
        district: district.id, state: state
      })
      [{}]
    else
      with_all_students_breakdown
    end
  end

  def having_district_value(array_of_hashes)
    array_of_hashes.select {|hash| hash['district_value']}
  end

  def max_year(array_of_hashes)
    array_of_hashes.max_by {|hash| hash['year']} || {}
  end

end
