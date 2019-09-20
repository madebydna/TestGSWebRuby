# frozen_string_literal: true

module SearchTableConcerns

  OVERVIEW_HEADER_NAMES = ['Type', 'Grades', 'Total students enrolled', 'Students per teacher', 'Reviews', 'District']
  COLLEGE_REMEDIATION_HEADER_NAMES = {"english": "Remediation: English", "math": "Remediation: Math"}
  STUDENT_PROGRESS_RATING = 'Student Progress Rating'
  ACADEMIC_PROGRESS_RATING = 'Academic Progress Rating'

  def academic_header_names
    ['Test Scores Rating', growth_progress_rating_header, 'College Readiness Rating', 'Equity Overview Rating']
  end
  
  def academic_header_hash
    academic_header_names.map do |title|
      tooltip = title.gsub('Rating', 'Description')
      {
          key: title,
          title: t(title, scope:'lib.search'),
          tooltip: t(tooltip, scope:'lib.search', default: ''),
          sortName: title.downcase.gsub(" ", "_")
      }
    end
  end

  def growth_progress_rating_header
    growth_data_proxy_state? ?  ACADEMIC_PROGRESS_RATING : STUDENT_PROGRESS_RATING
  end

  # This method checks if the state is a growth_data_proxy_data_state which will use Academic Progress Rating
  # Otherwise it will return false if it is a growth_data_state (uses Student Progress Rating) or if the state
  # doesn't have any data at all (N/A but will use SPR as a fallback) 
  def growth_data_proxy_state?
    # finds most frequent state if a la carte search is used and no state in query params
    most_frequent_state = mode(serialized_schools.map {|school| school.dig(:state) }) if state.nil?
    cache_data = StateCache.for_state('state_attributes', (state || most_frequent_state)).cache_data
    return false if cache_data.empty?
    cache_data['growth_type'] == ACADEMIC_PROGRESS_RATING
  end

  def equity_header_hash(schools)
    h = populated_test_score_fields
      .map do |field|
        name = Solr::SchoolDocument.rating_field_name_to_breakdown[field]
        name || field.titleize
      end
    # h = h.flatten.compact.uniq - ["All students"]
    h.map do |title|
      {
        key: title,
        title: t(title, default: t(title, scope: 'lib.search', default: title)),
        tooltip: t(title + '_tooltip', scope:'lib.search', default: ''),
        sortName: Solr::SchoolDocument.breakdown_to_rating_field_name[title]
      }
    end
  end

  def overview_header_hash
    OVERVIEW_HEADER_NAMES.map do |title|
      tooltip = title + ' Description'
      {
        key: title,
        title: t(title, scope:'lib.search', default: title),
        tooltip: t(tooltip, scope:'lib.search', default: '')
      }
    end
  end

  def translated_ethnicity_with_fallback
    @_translated_ethnicity ||= ethnicity != 'Low-income' ? I18n.t(ethnicity, default: ethnicity) : I18n.t("Low-income", scope:'lib.search')&.downcase
  end

  def cohort_count_header_hash
    {title: I18n.t('total_students_enrolled', scope: 'controllers.compare_schools_controller'), className: 'total-enrollment', key: 'total-enrollment'}
  end

  def percentage_of_students_by_breakdown_header_hash
    return nil if ethnicity.nil? || ethnicity.downcase == 'all students'
    {title: I18n.t('percentage_of_students', scope: 'controllers.compare_schools_controller', ethnicity: translated_ethnicity_with_fallback), className: 'ethnicity-enrollment', key: 'ethnicity-enrollment'}
  end

  def test_score_rating_by_ethnicity_header_hash
    return nil if ethnicity.nil?
    test_score_rating_key = ethnicity.downcase == 'all students' ? 'test_score_rating_for_all_students' : 'test_score_rating_for'
    {title: I18n.t(test_score_rating_key, scope: 'controllers.compare_schools_controller', ethnicity: translated_ethnicity_with_fallback), className: (sort_name == 'testscores' ? 'testscores highlight' : 'testscores'), key: 'testscores'}
  end

  def compare_schools_table_headers
    [cohort_count_header_hash, percentage_of_students_by_breakdown_header_hash, test_score_rating_by_ethnicity_header_hash].compact
  end

  def with_state_averages
    ->(s) { s["state_average"]}
  end

  def mode(array_of_values)
    array_of_values&.each_with_object(Hash.new(0)) { |v, h| h[v] += 1 }
                   &.max_by(&:last)
                   &.first
  end

  def generate_remediation_headers
    # Method that generate the correct table headers for the college success award page
    # Shows overall remediation data if available. Otherwise will try to show Math and English subjects
    # In absence of both, return nil and is removed from the array before sending to the frontend
    remediation_data = serialized_schools.map {|x| x[:remediationData]}.flatten
    remediation_data_overall = remediation_data&.select {|s| s["subject"] == 'All subjects'}

    if remediation_data_overall.present?
      remediation_state_average = mode(remediation_data_overall&.map(&with_state_averages))

      return {
        key: 'percentCollegeRemediation',
        title: t("Remediation", scope:'lib.college_success_award'),
        tooltip: t("Remediation", scope:'lib.college_success_award.tooltips'),
        footerNote: remediation_state_average && "#{t("State average", scope: 'lib.college_success_award')}: #{remediation_state_average}"
      }
    end

    remediation_data_english = remediation_data&.select {|s| s["subject"] == 'English'}
    remediation_data_math = remediation_data&.select {|s| s["subject"] == 'Math'}

    if (remediation_data_english.present? ||  remediation_data_math.present?)
      remediation_eng_state_average = mode(remediation_data_english&.map(&with_state_averages))
      remediation_math_state_average = mode(remediation_data_math&.map(&with_state_averages))

      return [{
                key: 'percentCollegeRemediationEnglish',
                title: t("English remediation", scope:'lib.college_success_award'),
                tooltip: t("English remediation", scope:'lib.college_success_award.tooltips'),
                footerNote: remediation_eng_state_average && "#{t("State average", scope: 'lib.college_success_award')}: #{remediation_eng_state_average}"
              },
              {
                key: 'percentCollegeRemediationMath',
                title: t("Math remediation", scope:'lib.college_success_award'),
                tooltip: t("Math remediation", scope:'lib.college_success_award.tooltips'),
                footerNote: remediation_math_state_average && "#{t("State average", scope: 'lib.college_success_award')}: #{remediation_math_state_average}"
              }]
    end
    nil
  end

  def college_success_award_header_arr
    persistence_data = serialized_schools.map {|x| x[:collegePersistentData]}.flatten
    enrollment_data = serialized_schools.map {|x| x[:collegeEnrollmentData]}.flatten

    persistence_state_average = mode(persistence_data&.map(&with_state_averages))
    enrollment_state_average = mode(enrollment_data&.map(&with_state_averages))

    [
      {
          key: 'clarifiedSchoolType',
          title: 'Type',
          tooltip: nil
      },
      {
          key: 'enrollment',
          title: t("Total enrolled", scope:'lib.college_success_award'),
          tooltip: t("Total enrolled", scope:'lib.college_success_award.tooltips')
      },
      {
          key: 'pieChartLowIncome',
          title: "% #{t("Low-income", scope:'lib.search')}",
          tooltip: t("Low-income", scope:'lib.college_success_award.tooltips')
      },
      {
          key: 'percentEnrolledInCollege',
          title: "% #{t("College enrollment", scope:'lib.college_success_award')}",
          tooltip: t("College_enrollment", scope:'lib.college_success_award.tooltips'),
          footerNote: enrollment_state_average && "#{t("State average", scope: 'lib.college_success_award')}: #{enrollment_state_average}"
      },
      generate_remediation_headers,
      persistence_data.present? ? {
          key: 'percentCollegePersistent',
          title: "#{t("Persistence", scope:'lib.college_success_award')} %",
          tooltip: t("Persistence", scope:'lib.college_success_award.tooltips'),
          footerNote: persistence_state_average && "#{t("State average", scope: 'lib.college_success_award')}: #{persistence_state_average}"
      } : nil,
      {
          key: 'districtAnchor',
          title: 'District',
          tooltip: nil
      }
    ].flatten.compact
  end
end