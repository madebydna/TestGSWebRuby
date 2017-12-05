require_relative '../step'
# e.g
# [
#   {
#     a: 1,
#     b: 2,
#     c: 3
#   }
# ]
# Transposer.new(:type, :value, [:a, :b, :c])
# becomes
# [
#   {
#     type: :a, # the label_fields
#     value: 1,  # the value_field
#   },
#   {
#     type: :b,
#     value: 2,
#   },
#   {
#     type: :c,
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
    record(row, "1 row to #{rows.length} rows")
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

  def fields_nil_or_empty(fields, message)
    raise ArgumentError, message if fields.nil? || fields.empty?
  end

  def fields_is_an_array(fields, message)
    raise ArgumentError, message unless fields.is_a?(Array)
  end

  def field_is_a_symbol(field, message)
    raise ArgumentError, message unless field.is_a?(Symbol)
  end

  def fields_contains_only_symbols(fields, message)
    unless fields.all? { |field| field.is_a?(Symbol) }
      raise ArgumentError, message
    end
  end

  def fields_contains_only_symbols_or_regexes(fields, message)
    unless fields.all? { |field| field.is_a?(Symbol) || field.is_a?(Regexp) }
      raise ArgumentError, message
    end
  end

  def label_fields=(label_fields)
    fields_nil_or_empty(label_fields, "Label fields are nil or empty.")
    fields_is_an_array(label_fields, "Label fields must be an array.")
    fields_contains_only_symbols(label_fields, "Label fields must contain only symbols.")
    @label_fields = label_fields
  end

  def value_field=(value_field)
    fields_nil_or_empty(value_field, "Value fields are nil or empty.")
    field_is_a_symbol(value_field, "Value field must be a symbol.")
    @value_field = value_field
  end

  def fields=(fields)
    fields_nil_or_empty(fields, "Fields are nil or empty.")
    fields_contains_only_symbols_or_regexes(fields, "Fields must contain only symbols or regexes.")
    @fields = fields
  end
end
