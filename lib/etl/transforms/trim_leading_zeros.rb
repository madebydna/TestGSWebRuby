require 'step'

class TrimLeadingZeros < GS::ETL::Step

  def initialize(field)
    self.field = field
  end

  def process(row)
    row[@field].sub!(/^0/, '') if row.has_key?(@field)
    row
  end

  def event_key
    @field
  end

  def field=(f)
    raise 'Field to cannot be nil or empty' if f.empty?
    @field = f
  end

end
