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

  def label
    data_set.data_type.name
  end

  def source_name
    data_set&.source&.name
  end

  def subject_name
    subject&.name
  end

  def breakdown_name
    if breakdown_id > 0
      breakdown.name
    else
      'All students'
    end
  end
end