class NcEntityLevelParser
  def initialize (row)
    @row = row
  end

  def parse
    @row[:entity_level] = get_value
    @row[:state_id] = get_state_id
    @row[:district_id] = get_district_id
  end

  def get_value
    if is_state?
      'state'
    elsif is_district?
      'district'
    elsif is_school?
      'school'
    end
  end

  def get_state_id
    @row[:school_id].to_s[0,3] if is_school?
  end

  def get_district_id
    @row[:school_id].to_s[0,3] if is_school? || is_district?
  end

  def is_state?
     /sea/i.match(@row[:school_id])
  end

  def is_district?
    /LEA/i.match(@row[:school_id])
  end

  def is_school?
    unless is_state? || is_district?
      true
    end
  end

end
