# frozen_string_literal: true

module Solr
  class FieldAccessor < SimpleDelegator
    attr_reader :block, :attr_name

    def initialize(field, attr_name, block)
      super(field)
      @field = field
      @attr_name = attr_name
      @block = block
    end

    def self.new_field_and_accessor(attr_name, field_name: attr_name, **opts, &block)
      FieldAccessor.new(
        ::Solr::Field.new(field_name, **opts),
        attr_name,
        block
      )
    end
  end
end