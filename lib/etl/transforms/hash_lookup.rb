require_relative '../step'

# Look a row's value up in a hash, and assign result to destination key
# Destination key defaults to original key, so will overwrite original value by
# default
class HashLookup < GS::ETL::Step
  def initialize(key, lookup_table, options = {})
    self.lookup_table = lookup_table
    self.key = key
    self.destination_key = options[:to] || key
    @ignore = options[:ignore] || []
  end

  def event_key
    @key
  end

  def process(row)
    lookup_value = row[@key]
    event_key = "#{@key}:#{lookup_value}"
    record(row, :executed, event_key)
    new_value = @lookup_table[lookup_value] || row[@destination_key]
    row[@destination_key] = new_value
    if @lookup_table.has_key?(lookup_value)
      record(row, :"mapped to #{new_value}", event_key)
    elsif @ignore.include?(lookup_value)
      record(row, :"#{lookup_value} ignored", event_key)
    else
      record(row, :'* Not Mapped *', event_key)
    end
    row
  end

  def lookup_table=(hash)
    raise 'Lookup table cannot be nil' if hash.nil?
    raise 'Lookup table must be a Hash' unless hash.is_a?(Hash)
    @lookup_table = hash
  end

  def key=(key)
    raise 'Key to transform cannot be nil or empty' if key.empty?
    raise "Key must be a symbol but was a #{key.class}" unless key.is_a?(Symbol)
    @key = key
  end

  def destination_key=(key)
    raise 'Destination key cannot be nil or empty' if key.empty?
    raise "Destination Key must be a symbol but was a #{key.class}" unless key.is_a?(Symbol)
    @destination_key = key
  end
end
