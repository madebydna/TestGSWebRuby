class SchoolDataHash

  attr_accessor :cachified_school, :cache, :characteristics, :performance, :data_hash, :options, :sub_group_to_return, :data_sets_and_years, :link_helper
  DEFAULT_DATA_SETS = [ 'basic_school_info' ]
  VALID_DATA_SETS = [ 'graduation_rate', 'a_through_g', 'caaspp_math', 'caaspp_english' ]

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
    @cachified_school = cachified_school
    @cache = cachified_school.cache_data || {}
    @characteristics = @cache['characteristics'] || {}
    @performance = @cache['performance'] || {}
    @data_hash = {}
    @link_helper = options[:link_helper]
    @data_sets_and_years = options[:data_sets_and_years]
    ds = validate_data_sets(@data_sets_and_years.try(:keys))

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
        city: cachified_school.city,
        state: cachified_school.state,
        url: link_helper.school_path(@cachified_school, lang: I18n.locale)
      }
    })
  end

  def get_characteristics_data(data_set, year, breakdown_to_use = sub_group_to_return)
    data = characteristics[data_set]

    breakdown = [*data].find do |value|
      value['original_breakdown'] == breakdown_to_use
    end

    get_data(breakdown, year)
  end


  def get_performance_data(data_set, year, subject, breakdown_to_use = sub_group_to_return)
    data = performance[data_set]

    breakdown = [*data].find do |value|
      value['original_breakdown'] == breakdown_to_use && value['subject'] == subject
    end

    get_data(breakdown, year)
  end


  def get_data(breakdown, year)
    if breakdown.present?
      {
        show_no_data_symbol: breakdown["school_value_#{year}"].nil?,
        value: breakdown["school_value_#{year}"].to_f.round,
        performance_level: breakdown['performance_level'],
        state_average: breakdown["state_average_#{year}"].to_f.round
      }
    else
      { show_no_data_symbol: true }
    end
  end

  def add_graduation_rate
    val = get_characteristics_data('4-year high school graduation rate', data_sets_and_years[:graduation_rate] )
    data_hash.merge!({graduation_rate: val})
  end

  def add_a_through_g
    val = get_characteristics_data('Percent of students who meet UC/CSU entrance requirements', data_sets_and_years[:a_through_g])
    data_hash.merge!({a_through_g: val})
  end

  def add_caaspp_math
    val = get_performance_data('California Assessment of Student Performance and Progress (CAASPP)', data_sets_and_years[:caaspp_math], 'Math')
    data_hash.merge!({caaspp_math: val})
  end

  def add_caaspp_english
    val = get_performance_data('California Assessment of Student Performance and Progress (CAASPP)', data_sets_and_years[:caaspp_english], 'English Language Arts')
    data_hash.merge!({caaspp_english: val})
  end

end
