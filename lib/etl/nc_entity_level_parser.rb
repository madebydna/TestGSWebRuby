class NcEntityLevelParser
  def initialize (row)
    @row = row
  end

  def parse
    @row[:entity_level] = get_value
    @row
  end

  def get_value
    if is_school?
      'school'
    elsif is_district?
      'district'
    elsif is_county?
      'county'
    elsif is_state?
      'state'
    end
  end

  def is_school?
    /[1-9]/.match(@row[:school_id])
  end

  def is_district?
    /[1-9]/.match(@row[:district_id]) && ! is_school?
  end

  def is_county?
    /[1-9]/.match(@row[:county_code]) &&
      ! is_school? && ! is_district?
  end

  def is_state?
    return true unless is_school? || is_district? || is_county?
  end

end
