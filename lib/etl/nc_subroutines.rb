class NcSubroutines
  def initialize (row)
    @row = row
  end

  def parse
    @row[:level_code] = get_level_code
    @row[:test_data_type] = get_test_data_type
    @row[:test_data_type_id] = get_test_data_type_id
    @row[:grade] = fix_grade
    @row[:value_float] = fix_value_float
    @row
  end

  def get_level_code
    if /ALL/i.match(@row[:grade])
      level_code = 'm,h'
    else
      level_code = 'e,m,h'
    end
    level_code
  end

  def get_test_data_type
    if /ma|rd|sc/i.match(@row[:subject])
      test_data_type = 'eog'
    else
      test_data_type = 'eoc'
    end
    test_data_type
  end

  def get_test_data_type_id
    test_data_type_id = nil
    if /eog/i.match(@row[:test_data_type])
      test_data_type_id = 35
    elsif /eoc/i.match(@row[:test_data_type])
      test_data_type_id = 34
    end
    test_data_type_id
  end

  def fix_grade
    grade = nil
    if @row[:test_data_type] == 'eoc'
      grade = 'All'
    else
      grade = @row[:grade]
    end
    grade
  end

  def fix_value_float
    if /<5/.match(@row[:value_float])
      value_float = 5
    else
      value_float = @row[:value_float]
    end
    value_float
  end

end