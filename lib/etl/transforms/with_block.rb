require 'step'

class WithBlock < GS::ETL::Step

  def initialize(&building_block)
    @building_block = building_block || proc { |v| v }
  end

  def process(row)
    row = @building_block.call(row)
    record(:row_manipulated)
    row
  end

  def event_key
    "Called block on row"
  end
end
