require 'forwardable'

class TableData
  include Enumerable
  extend Forwardable
  def_delegators :rows, :each, :<<

  attr_reader :columns, :data

  def initialize(data = {})
    @data = data
    @data[:rows] ||= []
    @rows = @data[:rows]
    @columns = Set.new

    if @data[:rows]
      @data[:rows].each {|row| add_column_for_row row}
    end
  end

  def rows
    @data[:rows]
  end

  def add_row(hash)
    @data[:rows] << hash
    add_column_for_row hash
  end

  def add_column_for_row(row_hash)
    row_hash.keys.each { |column| @columns.add column }
  end


  # For every row, look up the value of the specified column in a provided lookup_table.
  # If a match is found, overwrite the value
  def transform!(column, lookup_table)
    rows.each do |row|
      if lookup_table[row[column]]
        row[column] = lookup_table[row[column]]
      end
    end
    self
  end

  def size
    rows.size
  end

  def to_json
    @data.to_json
  end

  def sort_ascending(column)
    rows.sort_by{|row| row[column]}
  end

  def sort_descending(column)
    rows.sort_by{|row| row[column]}.reverse!
  end

  def sort_by(column, order_lookup_map)
    rows.sort_by{|row| order_lookup_map[row[column]]}
  end

end