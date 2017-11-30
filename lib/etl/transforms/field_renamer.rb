require_relative '../step'

class FieldRenamer < GS::ETL::Step

  def initialize(from, field_name_or_proc)
    self.from = from
    self.to = calculate_destination_field(field_name_or_proc)
  end

  def process(row)
    if can_process?(row)
      record(row, :renamed)
      row[@to] = row.delete(@from)
    else
      record(row, :skipped)
    end
    row
  end

  def can_process?(row)
    row.has_key?(@from) && ! row.has_key?(@to)
  end

  def event_key
    "#{@from} -> #{@to}"
  end

  private

  def calculate_destination_field(field_name_or_proc)
    if field_name_or_proc.is_a?(String) || field_name_or_proc.is_a?(Symbol)
      return field_name_or_proc
    elsif field_name_or_proc.is_a?(Proc)
      return field_name_or_proc.call(@from)
    else
      raise ArgumentError, 'must provide a field name (string, symbol) or proc'
    end
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
