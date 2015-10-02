class SchoolDataSortBuilder

  include SchoolDataValidator

  attr_accessor :options_hash, :school_data_sort

  DEFAULT_SORT = { sort: 'sd_school_id asc' }

  SORT_BY_BASE_MAP = Hash.new('').merge!({
    graduation_rate: 'sd_4_year_high_school_graduation_rate',
    a_through_g: 'sd_Percent_of_students_who_meet_UC_CSU_entrance_requirements',
    caaspp_math: 'sd_California_Assessment_of_Student_Performance_and_Progress_CAASPP_Math',
    caaspp_english: 'sd_California_Assessment_of_Student_Performance_and_Progress_CAASPP_English_Language_Arts'
  }).with_indifferent_access

  SORT_BREAKDOWN_MAP = Hash.new('').merge!({
    white:                             '_White',
    asian:                             '_Asian',
    native_american_or_native_alaskan: '_Native_American_or_Native_Alaskan',
    pacific_islander:                  '_Pacific_Islander',
    all_students:                      '_All_students',
    multiracial:                       '_Multiracial',
    filipino:                          '_Filipino',
    hispanic:                          '_Hispanic',
    african_american:                  '_African_American',
    male:                              '_Male',
    female:                            '_Female',
    not_economically_disadvantaged:    '_Not_economically_disadvantaged',
    students_with_disabilities:        '_Students_with_disabilities',
    general_education_students:        '_General_Education_students',
    economically_disadvantaged:        '_Economically_disadvantaged',
    limited_english_proficient:        '_Limited_English_proficient',
    not_limited_english_proficient:    '_Not_limited_English_proficient'
  }).with_indifferent_access

  SORT_YEAR_MAP = Hash.new('').merge!({
    2013 => '_2013',
    2014 => '_2014',
    2015 => '_2015',
  }).with_indifferent_access

  SORT_ASC_OR_DESC = Hash.new('_sortable_asc asc').merge!({
    asc: '_sortable_asc asc',
    desc: ' desc',
  }).with_indifferent_access

  def initialize(options_hash={})
    @options_hash     = options_hash.clone
    @school_data_sort = process_sort || DEFAULT_SORT
  end

  def process_sort
    if is_valid_school_data_field?(school_data_field)
      {sort: school_data_field + SORT_ASC_OR_DESC[options_hash[:sortAscOrDesc]]}
    end
  end

  #ex 'sd_4_year_high_school_graduation_rate_Multiracial_2013'
  def school_data_field
    @_school_data_field ||= SORT_BY_BASE_MAP[options_hash[:sortBy]] +
                            SORT_BREAKDOWN_MAP[options_hash[:sortBreakdown]] +
                            SORT_YEAR_MAP[options_hash[:sortYear]]
  end

end
