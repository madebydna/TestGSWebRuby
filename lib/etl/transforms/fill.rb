require 'step'

class Fill < GS::ETL::Step
  def initialize(hash_of_fields_and_values)
    @hash_of_fields_and_values = hash_of_fields_and_values
  end

  def process(row)
    row.merge!(@hash_of_fields_and_values)
    row
  end

end
