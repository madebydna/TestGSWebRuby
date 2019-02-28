require_relative '../display_range'
class CharacteristicsCaching::QueryResultDecorator
  extend Forwardable

  attr_accessor :data_set_with_values, :state
  def_delegators :@data_set_with_values, :[]

  def initialize(state, data_set_with_values)
    @data_set_with_values = data_set_with_values
    @state = state
  end

  def source
    description_obj = CharacteristicsCaching::Base.characteristics_descriptions["#{data_set_id}#{state}"]
    description_obj.source if description_obj
  end

  def label
    data_type = CharacteristicsCaching::Base.characteristics_data_types[data_type_id]
    data_type.description if data_type
  end

  def breakdown
    breakdown = CharacteristicsCaching::Base.characteristics_data_breakdowns[breakdown_id]
    if breakdown
      breakdown.breakdown
    else
      'All students'
    end
  end

  def school_value
    # For now, escape census values that go into school cache, since they can come from user input
    # School profiles potentially render these values in non-safe way
    value = data_set_with_values.school_value
    value = SafeHtmlUtils.html_escape_allow_entities(value) if value.is_a?(String)
    value
  end

  def district_value
    value = data_set_with_values.district_value
    value = SafeHtmlUtils.html_escape_allow_entities(value) if value.is_a?(String)
    value
  end

  def district_average
    data_set_with_values.district_value
  end

  def state_average
    # Needed since rails associations is not working properly with sharded databases
    CensusDataSet.on_db(state&.downcase)
                 .with_data_types(data_type_id)
                 .includes(:census_data_state_values)
                 .references(:census_data_state_values)
                 .select {|x| x== data_set_with_values}
                 .first
                 .state_value
  end

  def breakdown_id
    data_set_with_values.breakdown_id
  end

  def subject_id
    data_set_with_values.subject_id
  end

  def data_set_id
    data_set_with_values.id
  end

  def grade
    data_set_with_values.grade
  end

  def subject
    subject = TestScoresCaching::Base.test_data_subjects[subject_id]
    display_name = subject.name if subject
    display_name += ' subjects' if display_name == 'All'
    display_name
  end

  def data_type_id
    data_set_with_values.data_type_id
  end

  def year
    data_set_with_values.year
  end

  def created
    data_set_with_values.school_modified
  end

  def district_created
    data_set_with_values.district_modified
  end

  def performance_level
    DisplayRange.for({
      data_type:    'census',
      data_type_id: data_type_id,
      state:        state,
      subject_id:   subject_id,
      year:         year,
      value:        school_value
    })
  end
end
