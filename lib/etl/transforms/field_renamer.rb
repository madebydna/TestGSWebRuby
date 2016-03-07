require 'step'

class FieldRenamer < GS::ETL::Step

  def initialize(from, to)
    self.from = from
    self.to = to
  end

  def process(row)
    # unless row.has_key?(@from)
    #   raise "Tried to rename field '#{@from}' but it did not exist"
    # end
    if can_process?(row)
      record(:renamed)
      row[@to] = row.delete(@from)
    else
      record(:skipped)
    end
    row
  end

  def can_process?(row)
    row.has_key?(@from) && ! row.has_key?(@to)
  end

  def from=(field)
    raise 'Field to rename cannot be nil or empty' if field.empty?
    @from = field
  end

  def to=(field)
    raise 'Destination field after rename cannot be nil or empty' if field.empty?
    @to= field
  end

  def event_key
    "#{@from} -> #{@to}"
  end
  
end
