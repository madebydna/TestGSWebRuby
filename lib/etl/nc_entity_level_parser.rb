class NcEntityLevelParser
  def initialize (row)
    @row = row
  end

  def parse
    @row[:entity_level] = get_value
    @row
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
