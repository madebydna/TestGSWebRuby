# Look a row's value up in a hash, and assign result to destination key
# Destination key defaults to original key, so will overwrite original value by
# default
class HashLookupTransformer
  def initialize(key, lookup_table, destination_key = key)
    self.lookup_table = lookup_table
    self.key = key
    self.destination_key = destination_key
  end
  
  def process(row)
    value = row[@key]
    new_value = @lookup_table[value]
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


