require_relative '../step'
require_relative '../source'

class ExecuteBlockWhenRowGroupChanges < GS::ETL::Source
  attr_accessor :group_by_fields, :join_fields

  def initialize(group_by_fields, options = {}, &key_change_callback)
    options = options.merge({
      pass_rows_through_on_key_change: true,
      pass_rows_through_on_key_same: true
    })
    self.group_by_fields = group_by_fields
    @rows_in_group = []
    @key_change_callback = key_change_callback
    @pass_rows_through_on_key_same = options[:pass_rows_through_on_key_same]
    @pass_rows_through_on_key_change = options[:pass_rows_through_on_key_change]

    @key_same_callback = proc do |rows_in_group, row|
      rows_in_group << row
      @pass_rows_through_on_key_same ? row : nil
    end
  end

  def key_for_row(row)
    row.select { |column| group_by_fields.include?(column) }
  end

  def process(row)
    key = key_for_row(row)
    @last_key ||= key
    if @last_key && key != @last_key
      result = handle_key_change(row)
    else
      result = handle_key_same(row)
    end
    @last_key = key
    result
  end

  def handle_key_same(row)
    @key_same_callback.call(@rows_in_group, row)
  end

  def handle_key_change(row)
    new_rows = @key_change_callback.call(@rows_in_group)
    new_rows = [new_rows] unless new_rows.is_a?(Array)
    @rows_in_group = [row]
    new_rows += [row] if @pass_rows_through_on_key_change
    new_rows
  end
end
