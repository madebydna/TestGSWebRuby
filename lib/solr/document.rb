module Solr
  class Document
    include FromHashMethod
    include Solr::Fields

    class FieldAndBlock < SimpleDelegator
      attr_reader :block

      def initialize(field, block)
        super(field)
        @field = field
        @block = block
      end
    end

    def self.all_fields
      raise "Not implemented. Define self.#{__method__} in #{self.name}"
    end

    def self.new_field(*args, **opts, &block)
      FieldAndBlock.new(
        Field.new(*args, **opts),
        block
      )
    end

    def self.define_field_method(field, block)
      attr_writer(field.name)
      define_method(field.name) do
        return instance_variable_get(:"@#{field.name}") if instance_variable_defined?(:"@#{field.name}")
        rval = instance_eval(&field.block)
        instance_variable_set("@#{field.name}", rval)
        return rval
      end
    end

    def self.define_field_methods(*fields)
      fields.flatten.each { |f| define_field_method(f, f.block) }
    end

    def write_fields
      write_field(
        Field.new(:id, type: FieldTypes::STRING, required: true),
        type_and_unique_key
      )
      write_field(
        Field.new(:document_type, type: FieldTypes::STRING, required: true),
        self.document_type
      )
      write_document_fields
    end

    def write_document_fields
      self.class.all_fields.each do |field|
        write_field(field, send(field.name))
      end
    end
  end
end