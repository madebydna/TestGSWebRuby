class DataFileMapping
  attr_accessor :header_rows, :location, :layout, :columns

  def initialize(config)
    @config = config
    @header_rows = config[:header_rows].to_i # Defaults to 0
    @location = config[:location] or raise RequiredAttributeMissing, 'location'
    @layout = config[:layout] or raise RequiredAttributeMissing, 'layout'
  end

  def parse_layout!
    @columns = layout.each_with_object(Hash.new { |h,k| h[k] = {} }) do |(key, map), columns|
      # The key is the column type: like school_id, number_tested, and subject.
      # The map is how that column type is configured. Different objects have different rules:
      #  Integer/Fixnum: Get the value for this column type from each rows value in that column.
      #  Array: GSame as Integer/Fixnum, but for multiple columns.
      #  String/Symbol: The whole file gets the String/Symbol's value for this column type.
      #  Hash: A mix of the above. Maps the column type to the inner key for the inner values.
      #   EX: proficiency_band: { null: [20] } yields { 20 => { proficiency_band: :null } }
      parse_map!(columns, key, map)
    end
  end

  protected

  def parse_map!(columns, key, map)
    send("parse_#{map.class.to_s.downcase}!", columns, key, map)
  end

  def parse_integer!(columns, key, map)
    columns[map].merge!({ key => true } )
  end
  alias :parse_fixnum! :parse_integer!

  def parse_string!(columns, key, map)
    columns[:file].merge!({ key => map.to_s.to_sym })
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
        [*col].each do |c|
          columns[c].merge!({key => label})
        end
      else
        raise "Don't know how to handle #{ { key => map } } because '#{col}' is not an array or integer."
      end
    end
  end
end
