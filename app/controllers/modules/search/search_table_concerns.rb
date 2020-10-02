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

  # finds most frequent state if revelance search is used and no state in query params
  def most_frequent_state
    mode(serialized_schools.map {|school| school.dig(:state) })
  end

  # This method checks if the state is a growth_data_proxy_data_state which will use Academic Progress Rating
  # Otherwise it will return false if it is a growth_data_state (uses Student Progress Rating) or if the state
  # doesn't have any data at all (N/A but will use SPR as a fallback) 
  def growth_data_proxy_state?
    cache_data = StateCache.for_state('state_attributes', (state || most_frequent_state))&.cache_data
    return false if cache_data.nil?
    cache_data['growth_type'] == ACADEMIC_PROGRESS_RATING
  end

  def equity_header_hash
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
    # Shows overall remediation data for composite/any subject if available. Otherwise will try to show Math and English subjects
    # Also shows data for two or four year colleges for all subjects
    # In absence of both, return nil and is removed from the array before sending to the frontend
    all_headers = []

    # This is a hash with the possible keys Overall, Two-year, Four-year
    remediation_data = serialized_schools.map {|x| x[:remediationData]}

    overall = remediation_data.each_with_object([]) do |hash, accum|
      next unless hash["Overall"]
      accum << hash["Overall"]
    end.flatten

    all_headers += generate_overall_remediation_headers(overall)

    %w(Two Four).each do |num|
      array = remediation_data.each_with_object([]) do |hash, accum|
        next unless hash["#{num}-year"]
        accum << hash["#{num}-year"]
      end.flatten

      if array.present?
        state_avg = mode(array&.map(&with_state_averages))
        all_headers << {
          key: "percentCollegeRemediation#{num}Year",
          title: t("#{num} year Remediation", scope:'lib.college_success_award'),
          tooltip: t(array.first["data_type"], scope:'lib.college_readiness.data_point_info_texts'),
          footerNote: state_avg && "#{t("State average", scope: 'lib.college_success_award')}: #{state_avg}"
        }
      end
    end

    all_headers.presence
  end


  # This returns either one header for an aggregate subject (Any Subject or Composite Subject) or
  # up to two headers for Math and English
  def generate_overall_remediation_headers(overall_data)
    return [] unless overall_data.present?

    overall_all_subjects = overall_data.select do |s|
      MetricsCaching::Value::ALL_SUBJECTS.include? s["subject"]
    end

    if overall_all_subjects.present?
      state_avg = mode(overall_all_subjects&.map(&with_state_averages))
      [{
        key: 'percentCollegeRemediation',
        title: t("Remediation", scope:'lib.college_success_award'),
        tooltip: t("Remediation", scope:'lib.college_success_award.tooltips'),
        footerNote: state_avg && "#{t("State average", scope: 'lib.college_success_award')}: #{state_avg}"
      }]
    else
      %w(English Math).each_with_object([]) do |subject, accum|
        subject_array = overall_data.select {|s| s["subject"] == subject }
        if subject_array.present?
          state_avg = mode(subject_array&.map(&with_state_averages))
          subject = subject_array.first['subject']
          accum << {
            key: "percentCollegeRemediation#{subject}",
            title: t("#{subject} remediation", scope:'lib.college_success_award'),
            tooltip: t("#{subject_array.first['data_type']} remediation", scope:'lib.college_readiness.data_point_info_texts'),
            footerNote: state_avg && "#{t("State average", scope: 'lib.college_success_award')}: #{state_avg}"
          }
        end
      end
    end
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

  def table_headers
    return compare_schools_table_headers if breakdown.present?

    {
      'Overview' => overview_header_hash,
      'Equity' => equity_header_hash,
      'Academic' => academic_header_hash
    }
  end
end