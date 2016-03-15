require 'step'
# e.g
# [
#   {
#     a: 1,
#     b: 2,
#     c: 3
#   }
# ] 
# RowExploder.new('type', 'value', [:a, :b, :c])
# becomes
# [
#   {
#     type: 'a', # the label_field
#     value: 1,  # the value_field
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

  # label_field is used to store the name of the column that was used to
  # explode a new row
  # value_field is used to store the value that was in the cell for 
  # the column that was exploded
  def initialize(label_field, value_field, *fields)
    self.fields = fields
    self.label_field = label_field
    self.value_field = value_field
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

  def label_field=(label_field)
    if label_field == nil || label_field.length < 1
      raise ArgumentError, 'label_field must be provided'
    end
    @label_field = label_field
  end

  def value_field=(value_field)
    if value_field == nil || value_field.length < 1
      raise ArgumentError, 'value_field must be provided'
    end
    @value_field = value_field
  end

  def fields=(fields)
    if fields == nil || fields.length < 1
      raise ArgumentError, 'fields must be provided'
    end
    @fields = fields
  end
end
