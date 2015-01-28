class TestScoresCaching::QueryResultDecorator
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
      test_label: test_label,
      test_description: test_description,
      test_source: test_source,
      grade: grade,
      grade_label:  grade_label,
      subject: subject,
      year: year,
      number_students_tested: self['school_number_tested'],
      score: test_score,
      state_average: state_average,
      proficiency_band_id: self['proficiency_band_id'],
      proficiency_band_name: proficiency_band_name,
      breakdown_name: breakdown_name
    }.merge(test_description_hash)
  end

  def test_description
    description_obj = TestScoresCaching::Base.test_descriptions["#{data_type_id}#{state}"]
    description_obj.description if description_obj
  end

  def test_source
    description_obj = TestScoresCaching::Base.test_descriptions["#{data_type_id}#{state}"]
    description_obj.source if description_obj
  end

  def test_label
    # TODO: Find better place to cache (in memory) test data types, test descriptions, etc
    data_type = TestScoresCaching::Base.test_data_types[data_type_id]
    data_type.display_name if data_type
  end

  def breakdown_name
    breakdown = TestScoresCaching::Base.test_data_breakdowns[breakdown_id]
    breakdown.name if breakdown
  end

  def proficiency_band_name
    proficiency_band = TestScoresCaching::Base.proficiency_bands[self['proficiency_band_id']]
    proficiency_band.name if proficiency_band
  end

  def school_value
    self['school_value_text'] || self['school_value_float']
  end

  def state_value
    self['state_value_text'] || self['state_value_float']
  end

  def data_type_id
    self['data_type_id']
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

  def number_students_tested
    self['number_students_tested']
  end

end