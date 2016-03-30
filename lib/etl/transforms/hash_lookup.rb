require 'step'

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
    match_value = row[@key]
    event_key = "#{@key}:#{match_value}"
    record(:executed, event_key)
    if @lookup_table.has_key?(match_value)
      new_value = @lookup_table[match_value]
      record(:"mapped to #{new_value}", event_key)
      row[@destination_key] = new_value
    elsif @ignore.include?(match_value)
      record(:"#{match_value} ignored", event_key)
    else
      record(:'* Not Mapped *', event_key)
    end
    row
  end

  def lookup_table=(hash)
    raise 'Lookup table cannot be nil' if hash.nil?
    @lookup_table = hash
  end

  def key=(key)
    raise 'Key to transform cannot be nil or empty' if key.empty?
    @key = key
  end

  def destination_key=(key)
    raise 'Destination key cannot be nil or empty' if key.empty?
    @destination_key = key
  end
end
