class FieldRenamer
  def initialize(from, to)
    self.from = from
    self.to = to
  end

  def process(row)
    unless row.has_key?(@from)
      raise "Tried to rename field '#{@from}' but it did not exist"
    end
    row[@to] = row.delete(@from)
    row
  end

  def from=(field)
    raise 'Field to rename cannot be nil or empty' if field.empty?
    @from = field
  end

  def to=(field)
    raise 'Destination field after rename cannot be nil or empty' if field.empty?
    @to= field
  end
  
end
