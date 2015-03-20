# The class that handles a single data file's configuration layer.
# Things that are configured are:
# - location: Where the file exists.
# - header_rows: How many rows of header information are there before the data starts.
# - layout: What data is in each column.
# -- The layout is converted into a mapping of column number to descriptors, but only for value columns.
# -- A little confusing, but a value column is either labled value or number_tested: what goes into the value row in the db.
# -- See parse_layout! for more information about how the map is converted to this format.
#
# Example file mapping
# {
#   location: '2013/test_scores/sample_file.txt',
#   header_rows: 1,
#   layout: {
#     school_id: 5, # School IDs are found within column 5.
#     school_name: 6,
#     district_id: 4,
#     district_name: 6, # School names and district names are found in column 6.
#     value: [7, 8, 11, 20], # The values are in columns 1, 7, and 20.
#     number_tested: [2, 3],
#     breakdown: :white, # All values in sample_file.txt are tagged breakdown: white.
#     subject: {
#       math: [2, 7, 8],
#       writing: [3, 11, 20]
#     },
#     grade: 9,
#     proficiency_band: {
#       null: [8, 20], # The values in columns 8 and 20 are tagged proficiency_band: null.
#       level_1: [7, 11]
#     },
#   }
# }

class DataFileMapping
  attr_accessor :header_rows, :location, :layout, :columns

  def initialize(config)
    @config = config
    @header_rows = config[:header_rows].to_i # Defaults to 0
    @location = config[:location] or raise RequiredAttributeMissing, 'location'
    @layout = config[:layout] or raise RequiredAttributeMissing, 'layout'
  end

  def parse_layout!
    @base_value_description = {}
    @columns = layout.each_with_object(Hash.new { |h,k| h[k] = {} }) do |(key, map), columns|
      # As said above, the goal of this method is to convert the layout into a set of
      # descriptors for each value column, where a value column is either the value or the number_tested.
      # A descriptor can either be a location to look for information or the information itself.
      # For instance, { breakdown: 8 } means for each row of the file, the breakdown is the value of column 8
      # and { breakdown: :latino } means for each row of the file, the breakdown is latino.
      #
      # Method mechanics:
      # The key is the column type: like school_id, number_tested, and subject.
      # The map is how that column type is configured. Different objects have different rules:
      #  Integer/Fixnum: Get the value for this column type from each row's value in that column.
      #  Array: Same as Integer/Fixnum, but for multiple columns.
      #  String/Symbol: The whole file gets the String's/Symbol's value for this column type.
      #  Hash: A mix of the above. Maps the column type to the inner key for listed value columns.
      #   EX: proficiency_band: { null: [20] } yields { 20 => { proficiency_band: :null, ...other descriptors... } }
      #   Note that this is only for adding descriptors to value columns.
      parse_map!(columns, key, map)
    end
    @columns = @columns.each_with_object({}) do |(column, description), columns|
      columns[column] = description.merge(@base_value_description)
    end
  end

  protected

  def parse_map!(columns, key, map)
    send("parse_#{map.class.to_s.downcase}!", columns, key, map)
  end

  def parse_integer!(columns, key, map)
    if key == :number_tested || key == :value
      columns[map] = {value_type: key}
    else
      @base_value_description.merge!({ key => map } )
    end
  end
  alias :parse_fixnum! :parse_integer!

  def parse_string!(columns, key, map)
    @base_value_description.merge!({ key => map.to_s.to_sym } )
  end
  alias :parse_symbol! :parse_string!

  def parse_array!(columns, key, map)
    map.each do |m|
      parse_integer!(columns, key, m)
    end
  end

  def parse_hash!(columns, key, map)
    map.each do |label, col|
      # These parsers are slightly different because hashes have keys and labels
      if col.is_a?(Array) || col.is_a?(Integer)
        [*col].each do |value_column|
          columns[value_column].merge!({key => label})
        end
      else
        raise "Don't know how to handle #{ { key => map } } because '#{col}' is not an array or integer."
      end
    end
  end
end
