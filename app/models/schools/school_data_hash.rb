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

  DATATYPE_PARAM_MAP = {
    :graduation_rate => ["4-year high school graduation rate"],
    :a_through_g => ["Percent of students who meet UC/CSU entrance requirements"],
    :caaspp_math => ["California Assessment of Student Performance and Progress (CAASPP)", "Math"],
    :caaspp_english => ["California Assessment of Student Performance and Progress (CAASPP)", "English Language Arts"],
  }

  def initialize(cachified_school, options)
    @options, @sub_group_to_return = options, SUBGROUP_MAP[options[:sub_group_to_return]]
    @cachified_school = cachified_school
    @cache = cachified_school.merged_data || {}
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
        url: link_helper.send(:school_path, @cachified_school, lang: I18n.locale)
      }
    })
  end

  def get_data(data_set, year, subject = nil, breakdown_to_use = sub_group_to_return)
    data = cache[data_set.to_sym]

    breakdown = [*data].find do |value|
      if value[:original_breakdown] == breakdown_to_use
        if subject
          value[:subject] == subject
        else
          true
        end
      end
    end

    data_hash_for(breakdown, year)
  end


  def data_hash_for(breakdown, year)
    if breakdown.present?
      {
        show_no_data_symbol: breakdown["school_value_#{year}".to_sym].nil?,
        value: breakdown["school_value_#{year}".to_sym].to_f.round,
        performance_level: breakdown["performance_level_#{year}".to_sym],
        state_average: breakdown["state_average_#{year}".to_sym].to_f.round
      }
    else
      { show_no_data_symbol: true }
    end
  end

  DATATYPE_PARAM_MAP.each do |key, arr|
    data_type, subject = arr
    define_method "add_#{key}" do
      val = get_data(data_type, data_sets_and_years[key], subject)
      data_hash.merge!({key => val})
    end
  end
end
