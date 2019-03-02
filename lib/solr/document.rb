module Solr
  class Document
    include FromHashMethod
    include Fields

    # class methods

    def self.document_type
      raise "Not implemented. Define self.#{__method__} in #{self.name}"
    end

    def self.all_fields
      raise "Not implemented. Define self.#{__method__} in #{self.name}"
    end

    def self.new_field(*args, **opts, &block)
      FieldAccessor.new_field_and_accessor(*args, **opts, &block)
    end

    def self.define_field_method(field, block)
      attr_writer(field.attr_name)
      define_method(field.attr_name) do
        return instance_variable_get(:"@#{field.attr_name}") if instance_variable_defined?(:"@#{field.attr_name}")
        rval = instance_eval(&field.block)
        instance_variable_set("@#{field.attr_name}", rval)
        return rval
      end
    end

    def self.define_field_methods(*fields)
      fields.flatten.each { |f| define_field_method(f, f.block) }
    end

    DOCUMENT_TYPE = new_field(:document_type, type: FieldTypes::STRING) { self.class.document_type }
    ID = new_field(:document_id, type: FieldTypes::STRING, required: true, field_name: :id) { "#{document_type} #{id}" }

    def self.required_fields
      [ID, DOCUMENT_TYPE]
    end

    define_field_methods(required_fields)


    # instance methods for each document

    def unique_key
      raise "Not implemented. Define #{__method__} in #{self.class.name}"
    end

    def field_values
      (
        self.class.required_fields +
        self.class.all_fields
      ).each_with_object({}) do |field, hash|
        hash[field.name] = send(field.name)
      end
    end
  end
end