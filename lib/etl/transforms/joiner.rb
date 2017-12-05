class Joiner
  def initialize(data, left_field, right_field)
    @data = data
    @left_field = left_field
    @right_field = right_field
  end

  def process(row)
    left_value = row[@left_field].to_s
    row_to_merge = lookup_table[left_value]
    row.merge!(row_to_merge) if row_to_merge
    row
  end

  def lookup_table
    @_lookup_table ||= (
      table = {}
      @data.each do |row|
        table[row[@right_field].to_s] = row
      end
      table
    )
  end
end
