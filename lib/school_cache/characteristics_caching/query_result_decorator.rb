class CharacteristicsCaching::QueryResultDecorator
  extend Forwardable

  attr_accessor :data_set_with_values, :state
  def_delegators :@data_set_with_values, :[]

  def initialize(state, data_set_with_values)
    @data_set_with_values = data_set_with_values
    @state = state
  end

  def to_hash(data_set_and_value)
    {
        data_type_id: data_type_id,
        characteristic_label: characteristic_label,
        characteristic_source: characteristic_source,
        grade: grade,
        grade_label:  grade_label,
        subject: subject,
        year: year,
        characteristic_value: characteristic_value,
        state_value: state_value,
        breakdown_name: breakdown_name
    }.merge(test_description_hash)
  end

  def test_source
    description_obj = TestScoresCaching::Base.test_descriptions["#{data_type_id}#{state}"]
    description_obj.source if description_obj
  end

  def characteristic_label
    data_type = CharacteristicsCaching::Base.characteristics_data_types[data_type_id]
    data_type.description if data_type
  end

  def breakdown_name
    breakdown = CharacteristicsCaching::Base.characteristics_data_breakdowns[breakdown_id]
    breakdown.breakdown if breakdown
  end

  def characteristic_value
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

  def grade_label
    grade_label = "GRADE " + grade.value.to_s
    if grade.name && grade.name.start_with?('All')
      if level_code.levels.size >= 3
        grade_label = "School-wide"
      else
        grade_label = level_code.levels.collect(&:long_name).join(" and ") + " school"
      end
    end
    grade_label
  end

  def grade
    Grade.from_string(self['grade'])
  end

  def level_code
    LevelCode.new(self['level_code'])
  end

  def subject
    subject = TestScoresCaching::Base.test_data_subjects[subject_id]
    display_name = subject.name if subject
    display_name += ' subjects' if display_name == 'All'
    display_name
  end

  def data_type_id
    self['data_type_id']
  end

  def year
    self['year']
  end

end