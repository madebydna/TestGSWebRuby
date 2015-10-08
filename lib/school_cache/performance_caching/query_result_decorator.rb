class PerformanceCaching::QueryResultDecorator < TestScoresCaching::QueryResultDecorator
  def created
    self['created']
  end

  def grade
    self['grade']
  end

  def display_target
    self['display_target']
  end

  def rating?
    display_target.include?('ratings')
  end

  def performance_level
    DisplayRange.for({
      data_type:    'test',
      data_type_id: data_type_id,
      state:        state,
      year:         year,
      value:        school_value
    })
  end

  alias :breakdown :breakdown_name
  alias :label :test_label
  alias :source :test_source
  alias :state_average :state_value
end
