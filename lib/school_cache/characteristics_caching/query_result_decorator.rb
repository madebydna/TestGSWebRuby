class CharacteristicsCaching::QueryResultDecorator
  extend Forwardable

  attr_accessor :data_set_with_values, :state
  def_delegators :@data_set_with_values, :[]

  def initialize(state, data_set_with_values)
    @data_set_with_values = data_set_with_values
    @state = state
  end

  def to_hash
    {
        characteristic_label: characteristic_label,
        characteristic_source: characteristic_source,
        grade: grade,
        subject: subject,
        year: year,
        characteristic_value: school_value,
        state_average: state_value,
        breakdown_name: breakdown_name
    }
  end

  def characteristic_source
    description_obj = CharacteristicsCaching::Base.characteristics_descriptions["#{data_set_id}#{state}"]
    description_obj.source if description_obj
  end

  def characteristic_label
    data_type = CharacteristicsCaching::Base.characteristics_data_types[data_type_id]
    data_type.description if data_type
  end

  def breakdown_name
    breakdown = CharacteristicsCaching::Base.characteristics_data_breakdowns[breakdown_id]
    if breakdown
      breakdown.breakdown
    else
      'no_breakdown_specified'
    end
  end

  def school_value
    self['school_value_text'] || self['school_value_float']
  end

  def state_value
    self['state_value_text'] || self['state_value_float']
  end

  def breakdown_id
    self['breakdown_id']
  end

  def subject_id
    self['subject_id']
  end

  def data_set_id
    self['id']
  end

  def grade
    self['grade'] || 'no_grade_specified'
  end

  def level_code
    LevelCode.new(self['level_code'])
  end

  def subject
    subject = TestScoresCaching::Base.test_data_subjects[subject_id]
    display_name = subject.name if subject
    display_name += ' subjects' if display_name == 'All'
    display_name || 'no_subject_specified'
  end

  def data_type_id
    self['data_type_id']
  end

  def year
    self['year']
  end

end