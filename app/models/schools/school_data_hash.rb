class SchoolDataHash

  attr_accessor :cachified_school, :cache, :characteristics,:data_hash, :options, :sub_group_to_return

  DEFAULT_DATA_SETS = [ 'basic_school_info' ]
  VALID_DATA_SETS = [ 'graduation_rate', 'a_through_g' ]

  def initialize(cachified_school, options)
    @options, @sub_group_to_return = options, options[:sub_group_to_return]
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
        type: cachified_school.type,
      }
    })
  end

  #use breakdown or original_breakdown?
  def get_characteristics_data(data_set, sub_group = sub_group_to_return)
    grad_data = characteristics[data_set]
    breakdown_to_use = sub_group_to_return || 'all students'

    sub_group = [*grad_data].find { |gd| gd['breakdown'].try(:downcase) == breakdown_to_use }
    sub_group.present? ? {value: sub_group['school_value'].to_i, performance_level: sub_group['performance_level']} : {}
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
