class SchoolDataHash

  attr_accessor :cachified_school, :cache, :characteristics,:data_hash, :options, :sub_group_to_return, :school_value, :state_average

  DEFAULT_DATA_SETS = [ 'basic_school_info' ]
  VALID_DATA_SETS = [ 'graduation_rate', 'a_through_g' ]

  SUBGROUP_MAP = Hash.new('All students').merge!({
    white:                             'White',
    asian:                             'Asian',
    native_american_or_native_alaskan: 'Native American or Native Alaskan',
    pacific_islander:                  'Pacific Islander',
    all_students:                      'All students',
    multiracial:                       'Multiracial',
    filipino:                          'Filipino',
    hispanic:                          'Hispanic',
    african_american:                  'African American',
    male:                              'Male',
    female:                            'Female',
    not_economically_disadvantaged:    'Not economically disadvantaged',
    students_with_disabilities:        'Students with disabilities',
    general_education_students:        'General-Education students',
    economically_disadvantaged:        'Economically disadvantaged',
    limited_english_proficient:        'Limited English proficient',
    not_limited_english_proficient:    'Not limited English proficient'
  }).with_indifferent_access

  def initialize(cachified_school, options)
    @options, @sub_group_to_return = options, SUBGROUP_MAP[options[:sub_group_to_return]]
    @school_value = "school_value_#{options[:year]}"
    @state_average = "state_average_#{options[:year]}"
    @cachified_school = cachified_school
    @cache = cachified_school.cache_data || {}
    @characteristics = @cache['characteristics'] || {}
    @data_hash = {}
    ds = validate_data_sets(options[:data_sets])

    ds.each { | ds_callback | send("add_#{ds_callback}") } if cachified_school.present?
  end

  private

  def validate_data_sets(data_sets)
    ([*data_sets] & VALID_DATA_SETS) + DEFAULT_DATA_SETS
  end

  def add_basic_school_info
    data_hash.merge!({
      school_info: {
        gradeLevel: cachified_school.process_level,
        name: cachified_school.name,
        type: I18n.db_t(cachified_school.type).to_s.titleize,
      }
    })
  end

  def get_characteristics_data(data_set, breakdown_to_use = sub_group_to_return)
    data = characteristics[data_set]

    breakdown = [*data].find do |value|
      value['original_breakdown'] == breakdown_to_use
    end
    if breakdown.present?
      {
        value: breakdown[school_value].to_f.round,
        performance_level: breakdown['performance_level'],
        state_average: breakdown[state_average].to_f.round
      }
    else
      {}
    end
  end

  def add_graduation_rate
    val = get_characteristics_data('4-year high school graduation rate')
    data_hash.merge!({graduation_rate: val})
  end

  def add_a_through_g
    val = get_characteristics_data('Percent of students who meet UC/CSU entrance requirements')
    data_hash.merge!({a_through_g: val})
  end

end
