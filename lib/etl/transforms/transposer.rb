require_relative '../step'
# e.g
# [
#   {
#     a: 1,
#     b: 2,
#     c: 3
#   }
# ] 
# Transposer.new('type', 'value', [:a, :b, :c])
# becomes
# [
#   {
#     type: 'a', # the label_fields
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
class Transposer < GS::ETL::Step

  # label_fields is used to store the name of the column that was used to
  # explode a new row
  # value_field is used to store the value that was in the cell for 
  # the column that was exploded
  def initialize(label_fields, value_field, *fields)
    self.fields = fields
    self.label_fields = [*label_fields]
    self.value_field = value_field
  end

  def process(row)
    rows = fields_to_transpose(row).map do |field|
      value_for_field = row[field]
      new_row = row.clone
      @label_fields.each { |f| new_row[f] = field }
      new_row[@value_field] = value_for_field
      new_row
    end
    record("1 row to #{rows.length} rows")
    rows
  end

  def event_key
    @label_fields
  end

  def fields_to_transpose(row)
    row.keys.select do |field|
      @fields.any? do |match|
        match == field ||
          (match.is_a?(Regexp) && !!(match =~ field))
      end
    end
  end

  def label_fields=(label_fields)
    if label_fields.nil? || label_fields.empty?
      raise ArgumentError, 'label_fields must be provided'
    end
    @label_fields = label_fields
  end

  def value_field=(value_field)
    if value_field.nil? || value_field.empty?
      raise ArgumentError, 'value_field must be provided'
    end
    @value_field = value_field
  end

  def fields=(fields)
    raise ArgumentError, 'fields must be provided' if fields.empty?
    @fields = fields
  end
end
