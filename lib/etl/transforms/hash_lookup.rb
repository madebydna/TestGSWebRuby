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
    value = row[@key]
    new_value = @lookup_table[value]
    event_key = "#{@key}:#{value}"
    record(:executed, event_key)
    if @ignore.include?(value)
      record(:"#{new_value} ignored")
    elsif @lookup_table.has_key?(value)
      record(:"mapped to #{new_value}", event_key) 
    else
      record(:'* Not Mapped *', event_key)
    end
    row[@destination_key] = new_value
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


