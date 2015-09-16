module ConstructFromHash
  extend ActiveSupport::Concern

  def self.new_from_hash(hash)
    obj = self.new
    hash.each { |k,v| obj.send("#{k}=", v) if obj.methods.include?("#{k}=") }
  end

  included do
    def self.define_initialize_that_accepts_hash
      old_new = method(:new)
      define_singleton_method(:new) do |*args, &block|
        obj = old_new.call
        if args.first.is_a?(Hash)
          args.first.each { |k,v| obj.send("#{k}=", v) }
        end
        obj
      end
    end

    # defines a getter and setter method
    # setter method implementation will delegate to a specified method on specified class
    # method to delegate must be a class method and will default to #new
    def self.delegating_attr_accessor(name, klass, options = {})
      method_to_delegate_to = options[:to] || :new

      # define setter method
      define_method("#{name}=") do |object|
        value = object
        if options[:as] == :array && object.is_a?(Array)
          value = object.map { |o| klass.send(method_to_delegate_to, o) }
        elsif options[:as] == :hash && object.is_a?(Hash)
          value = object.each_with_object({}) do |(key, value), hash|
            hash[key] = klass.send(method_to_delegate_to, value)
          end
        else
          value = klass.send(method_to_delegate_to, object)
        end
        instance_variable_set("@#{name}".to_sym, value)
      end

      # define getter method
      attr_reader name
    end
  end
end