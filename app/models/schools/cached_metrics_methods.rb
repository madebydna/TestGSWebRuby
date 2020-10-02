module CachedMetricsMethods
  include MetricsCaching::CommonCachedMetricsMethods

  NO_DATA_SYMBOL = '?'
  NO_ETHNICITY_SYMBOL = 'n/a'
  REMEDIATION_SUBJECTS_FOR_CSA = ['English', 'Math']
  COLLEGE_ENROLLMENT_DATA_TYPES = [
    "Percent Enrolled in College Immediately Following High School", # 178
    "Percent enrolled in any institution of higher learning in the last 0-16 months", # 262
    "Percent enrolled in any postsecondary institution within 12 months after graduation", # 444
    "Percent enrolled in any postsecondary institution within 24 months after graduation", # 456
    "Percent of students who will attend in-state colleges", # 321
    "Percent enrolled in any public in-state postsecondary institution within 12 months after graduation", # 443
    "Percent enrolled in any public in-state postsecondary institution or intended to enroll in any out-of-state institution, or in-state private institution within 18 months after graduation", #458
    "Percent enrolled in any public in-state postsecondary institution within the immediate fall after graduation", # 459
    "Percent enrolled in any in-state postsecondary institution within 12 months after graduation", # 453
  ]

  def students_enrolled(opts = {})
    opts.reverse_merge!(grade: 'All', number_value: true)
    metrics_value_by_name('Enrollment', opts)
  end

  def numeric_enrollment
    metrics_value_by_name('Enrollment', grade: 'All')
  end

  def ratio_of_students_to_full_time_teachers
    metrics['Ratio of students to full time teachers']&.first&.fetch('school_value', nil)&.to_f&.round
  end

  def metrics_value_by_name(name, options={})
    if valid_metric_cache(metrics[name])
      metrics[name].each do |metric|
        if options.present?
          if options.key? :grade
            next unless metric['grade'] == options[:grade]
          end
          if options[:number_value]
            return number_with_delimiter(metric['school_value'].to_i, delimiter: ',')
          else
            return metric['school_value']
          end
        else
          return metric['school_value']
        end
      end
    end
    NO_DATA_SYMBOL unless options[:allow_nil]
  end

  def created_time(name)
    if valid_metric_cache(metrics[name]) && metrics[name].present? && metrics[name].first['created'].present?
      Time.parse(metrics[name].first['created'])
    end
  end

  def school_leader
    metrics_value_by_name('Head official name', grade: 'NA', allow_nil: true)
  end

  def school_leader_email
    metrics_value_by_name('Head official email address', grade: 'NA', allow_nil: true)
  end

  def ethnicity_data
    metrics['Ethnicity'] || []
  end

  def enroll_in_college
    # find max year for data types with all
    max_year = 0
    csa_college_enrollment_data = metrics.slice(*COLLEGE_ENROLLMENT_DATA_TYPES)
    all_students_hashes = csa_college_enrollment_data.values.flatten.select { |h| h['breakdown'] == 'All students'}
    all_students_hashes.each do |h|
      max_year = h['year'] if h['year'] > max_year
    end
    # select out data types with max year
    data_with_max_year = all_students_hashes.select { |h| h['year'] == max_year }
    return {} if data_with_max_year.empty?
    {}.tap do |hash|
      hash["school_value"] = "#{data_with_max_year.first['school_value'].to_f.round(0)}%"
      hash["state_average"] = "#{data_with_max_year.first['state_average'].to_f.round(0)}%" if data_with_max_year.first['state_average']
    end
  end

  def stays_2nd_year
    persistence_data = metrics['Percent Enrolled in College and Returned for a Second Year'] || []
    all_students_value = persistence_data.find { |h| h['breakdown'] == 'All students'}
    return [] unless all_students_value.present?
    {}.tap do |hash|
      hash["school_value"] = "#{all_students_value['school_value'].to_f.round(0)}%"
      hash["state_average"] = "#{all_students_value['state_average'].to_f.round(0)}%" if all_students_value['state_average']
    end
  end

  def graduates_remediation_for_college_success_awards
    return {} unless graduates_remediation.present?
    result = {}

    if graduates_remediation['Percent Needing Remediation for College']
      # The "Overall" remediation data type is the only one that we'd want to display English/Math
      # data for if the aggregate subject (Any Subject or Composite Subject) is not available
      overall_data = graduates_remediation['Percent Needing Remediation for College']
              .for_all_students
              .all_subjects_or_subjects_in(REMEDIATION_SUBJECTS_FOR_CSA)
              .having_school_value
      if overall_data.present?
        result["Overall"] = overall_data.map do |datum|
          remediation_hash(datum)
        end
      end
    end

    if (two_year_college_data = graduates_remediation['Percent needing remediation in in-state public 2-year institutions'])
      datum = two_year_college_data.for_all_students
        .no_subject_or_all_subjects
        .having_school_value.first
      result["Two-year"] = Array.wrap(remediation_hash(datum)) if datum
    end

    if (four_year_college_data = graduates_remediation['Percent needing remediation in in-state public 4-year institutions'])
      datum = four_year_college_data.for_all_students
                .no_subject_or_all_subjects
                .having_school_value.first
      result["Four-year"] = Array.wrap(remediation_hash(datum)) if datum
    end

    result
  end

  def style_school_value(value)
    value = value.to_s.scan(/[0-9.]+/).first.to_f
    return nil unless value

    value.round(0)
  end

  def style_school_value_as_percent(data_name)
    return NO_DATA_SYMBOL unless valid_metric_cache(metrics[data_name])
    value = metrics[data_name].first['school_value'].to_f
    return nil unless value
    "#{value.round(0)}%"
  end

  def free_and_reduced_lunch
    style_school_value_as_percent('Students participating in free or reduced-price lunch program')
  end

  def free_or_reduced_price_lunch_data
    metrics['Students participating in free or reduced-price lunch program'] || []
  end

  protected

  def valid_metric_cache(cache)
    if cache && cache.is_a?(Array)
      true
    else
      false
    end
  end

  private

  def remediation_hash(datum)
    {}.tap do |hash|
      hash["data_type"] = datum.data_type
      hash["subject"] = datum.subject
      hash["school_value"] = "#{style_school_value(datum.school_value)}%"
      hash["state_average"] = "#{style_school_value(datum.state_average)}%" if datum.state_average
    end
  end

end
