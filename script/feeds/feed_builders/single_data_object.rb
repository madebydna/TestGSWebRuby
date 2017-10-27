module Feeds
  # This is used as a information holder for any data entry
  class SingleDataObject

    attr_accessor :key, :value, :attributes

    # attributes is an optional hash
    def initialize(key, value, attributes={})
      @key = key
      @value = value
      @attributes = attributes
    end
  end

end
