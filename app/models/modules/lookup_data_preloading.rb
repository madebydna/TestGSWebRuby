require 'active_support/concern'

module LookupDataPreloading
  extend ActiveSupport::Concern

  included do

    def self.preload_all(class_as_symbol, opts = {})
      as_name = opts[:as] || class_as_symbol
      foreign_key = opts[:foreign_key] || as_name
      field = opts[:field]

      klass = Object.const_get class_as_symbol.to_s.camelize

      #Define the getter
      define_method(as_name.to_s) do

        # get the ID of the thing to look up
        id = read_attribute "#{foreign_key.to_s}".to_sym

        object = klass.class_variable_get(:@@all_by_id)[id] unless id.nil?
      end

      if not klass.class_variable_defined? :@@all_by_id
        # Precache data from the DB
        all_vals = klass.all

        cache_data =
          Hash[all_vals.map do |obj|
            if field
              [obj.id, field.nil? ? obj : obj.send(field)]
            else
              [obj.id, obj]
            end
          end]

        klass.class_variable_set(:@@all_by_id, cache_data)
      end

    end

  end
end
