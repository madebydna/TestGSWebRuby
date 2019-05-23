# frozen_string_literal: true

module SearchTableConcerns

  ACADEMIC_HEADER_NAMES = ['Test Scores Rating', 'Academic Progress Rating', 'College Readiness Rating', 'Advanced Courses Rating', 'Equity Overview Rating']
  OVERVIEW_HEADER_NAMES = ['Type', 'Grades', 'Total students enrolled', 'Students per teacher', 'Reviews', 'District']
  COLLEGE_REMEDIATION_HEADER_NAMES = {"english": "Remediation: English", "math": "Remediation: Math"}

  def academic_header_hash
    ACADEMIC_HEADER_NAMES.map do |title|
      tooltip = title.gsub('Rating', 'Description')
      {
          key: title,
          title: t(title, scope:'lib.search'),
          tooltip: t(tooltip, scope:'lib.search', default: ''),
          sortName: title.downcase.gsub(" ", "_")
      }
    end
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

  def with_state_averages
    lambda {|s| s["state_average"]}
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