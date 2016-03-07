require 'step'
# e.g
# [
#   {
#     a: 1,
#     b: 2,
#     c: 3
#   }
# ] 
# RowExploder.new([:a, :b, :c], 'type', 'value')
# becomes
# [
#   {
#     type: 'a',
#     value: 1,
#   },
#   {
#     type: 'b',
#     value: 2,
#   },
#   {
#     type: 'c',
#     value: 3,
#   }
# ]
class RowExploder < GS::ETL::Step

  def initialize(label_field, value_field, *fields)
    @fields = *fields
    @label_field = label_field
    @value_field = value_field
  end

  def process(row)
    rows = @fields.map do |field|
      value_for_field = row[field]
      new_row = row.clone
      new_row[@label_field] = field
      new_row[@value_field] = value_for_field
      new_row
    end
    record("1 row to #{rows.length} rows")
    rows
  end

  def event_key
    @label_field
  end
end
