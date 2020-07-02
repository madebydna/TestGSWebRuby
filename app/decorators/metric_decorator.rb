class MetricDecorator < SimpleDelegator
  def initialize(metric)
    super(metric)
  end

  def data_type_id
    data_set.data_type_id
  end

  def year
    data_set.date_valid.year
  end

  def source_date_valid
    data_set.date_valid
  end

  def label
    data_set.data_type.name
  end

  def source_name
    data_set&.source&.name
  end

  def subject_name
    subject&.name
  end

  # In Omni:
  # 0: Not Applicable
  # 1: All Students (capitalized)
  def breakdown_name
    if breakdown_id > 1
      breakdown.name
    else
      # forcing lowercase version for now
      # as it is used everywhere for string comparison
      'All students'
    end
  end

  # Even though breakdown has many breakdown_tags
  # in practice there is no breakdown
  # that has more than one breakdown_tag
  def breakdown_tags
    breakdown.breakdown_tags.first.try(:tag)
  end
end