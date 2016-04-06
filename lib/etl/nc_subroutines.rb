class NcSubroutines
  def initialize (row)
    @row = row
  end

  def parse
    @row[:test_data_type] = get_test_data_type
    @row[:grade] = fix_grade
    @row[:level_code] = get_level_code
    @row[:test_data_type_id] = get_test_data_type_id
    @row[:subject] = downcase_subject
    @row[:breakdown] = downcase_breakdown
    @row[:value_float] = fix_value_float
    @row
  end

  def get_test_data_type
    /ma|rd|sc/i.match(@row[:subject]) ? 'eog' : 'eoc'
  end

  def fix_grade
    @row[:test_data_type] == 'eoc' ? 'All' : @row[:grade]
  end

  def get_level_code
    /All/i.match(@row[:grade]) ? 'm,h' : 'e,m,h'
  end

  def get_test_data_type_id
    /eog/i.match(@row[:test_data_type]) ? 35 : 34
  end

  def downcase_subject
    subject = nil
    if @row[:subject]
      subject = @row[:subject].downcase
    end
  end

  def downcase_breakdown
    breakdown = nil
    if @row[:breakdown]
      subject = @row[:breakdown].downcase
    end
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