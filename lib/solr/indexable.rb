# frozen_string_literal: true

module Solr
  module Indexable
    def self.type
      raise 'Not implemented'
    end

    def type
      self.class.type
    end

    def write_field(field, value)
      @_field_values ||= {}
      @_field_values[field] = value 
    end

    def any_fields_added?
      field_values.length > 2 # number of default fields added in build
    end

    def field_values
      return @_field_values if @built == true
      write_fields
      @built = true
      @_field_values
    end

    def type_and_unique_key
      "#{type} #{unique_key}"
    end

    def unique_key
      raise 'Not implemented'
    end
  end
end
