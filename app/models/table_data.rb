require 'forwardable'

class TableData
  include Enumerable
  extend Forwardable
  def_delegators :@rows, :each, :<<

  attr_reader :rows, :columns

  def initialize
    @rows = []
    @columns = Set.new
  end

  def add_row(hash)
    @rows << hash
    hash.keys.each { |column| @columns.add column }
  end

  # For every row, look up the value of the specified column in a provided lookup_table.
  # If a match is found, overwrite the value
  def transform!(column, lookup_table)
    @rows.each do |row|
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
    {
        columns: @columns,
        rows: @rows
    }
  end

  def sort_ascending(column)
    @rows.sort_by{|row| row[column]}
  end

  def sort_descending(column)
    @rows.sort_by{|row| row[column]}.reverse!
  end

  def sort_by(column, order_lookup_map)
    @rows.sort_by{|row| order_lookup_map[row[column]]}
  end

end