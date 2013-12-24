require 'forwardable'

class TableData
  include Enumerable
  extend Forwardable
  def_delegators :rows, :each, :<<

  attr_reader :columns

  # Generate a TableData from a json object
  def self.from_json(json)
    table_data = TableData.new
    json.each { |k, v| table_data.send "#{k}=", v }
    return table_data
  end

  # Turn a hash into an array of hashes, using column1_name and column2_name as the keys for the new hashes
  def self.from_hash(hash, column1_name, column2_name)
    rows =
      hash.inject([]) do |array, (key, val)|
        h = {}
        h[column1_name] = key
        h[column2_name] = val
        array << h
        array
      end
    TableData.new rows
  end

  # Allows two methods of instantiation:
  #  Provide only rows, where rows is an array of hashes
  #  Provide rows and pluck_columns, where rows is an array of objects and pluck_columns are the attributes to use
  def initialize(rows = [], pluck_columns = [])
    @columns = Set.new

    if rows.is_a? Hash
      rows = rows.values
    end

    if rows.first.is_a? Array
      rows = rows.inject([], &:+)
    end

    if pluck_columns.any?
      rows = pluck_attributes rows, pluck_columns
    end

    if rows.any?
      rows.each { |row| add_columns_for_row row }
    end

    @rows = rows
    @data = {
        rows: rows,
        columns: @columns
    }
  end

  # given an array of objects, build a new array of hashes. Calls each attribute method on each given object
  # each hash should contain all of the provided attributes
  def self.pluck_attributes(objects = [], attributes = [])
    objects.map do |object|
      attributes.inject({}) { |hash, attribute| hash[attribute] = object.send attribute; hash }
    end
  end

  def rows
    @data[:rows]
  end

  def add_row(hash)
    @data[:rows] << hash
    add_columns_for_row hash
  end

  def add_columns_for_row(row_hash)
    row_hash.keys.each { |column| @columns.add column }
  end

  # for each row, remove all keys that dont exist in provided array
  def retain_columns!(keys = [])
    rows.each do |row|
      row.keep_if { |key, _| keys.include? key }
    end
  end

  # For every row, look up the value of the specified column in a provided lookup_table.
  # If a match is found, overwrite the value
  def transform_column!(column, lookup_table)
    rows.each do |row|
      data = row[column]

      if data.is_a? Array
        row[column] = data.map do |d|
          if lookup_table[d]
            lookup_table[d]
          else
            d
          end
        end
      else
        if lookup_table[data]
          row[column] = lookup_table[data]
        end
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
    rows.sort_by { |row| row[column] }
  end

  def sort_descending(column)
    rows.sort_by { |row| row[column] }.reverse!
  end

  def sort_by(column, order_lookup_map)
    rows.sort_by { |row| order_lookup_map[row[column]] }
  end

  # for each row in the given table_data, generate an array [label_column, value_column]
  def to_piechart(label_column, value_column)
    rows.map { |row| ["#{row[label_column]}", row[value_column].to_i] }
  end

end