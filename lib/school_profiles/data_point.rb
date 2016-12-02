module SchoolProfiles
  class DataPoint
    module Formatters
      def self.round(value)
        value.round
      end

      def self.percent(value)
        "#{value}%"
      end

      def self.to_f(value)
        value.to_f
      end
    end

    attr_reader :value

    def initialize(value, *formatters)
      @value = value
      @formatters = formatters
    end

    def method_missing(method, *args)
      if @value.respond_to?(method)
        @value.send(method, *args)
      else
        super
      end
    end

    def apply_formatting(*formatters)
      @formatters = @formatters.concat(formatters.flatten.compact)
      self
    end

    def to_s
      value.to_s
    end

    def ==(other)
      value == other
    end

    def format
      return nil if value.nil?
      @formatters.reduce(value) { |a, e| Formatters.method(e).call(a) }
    end

    def respond_to_missing?(method, include_private = false)
      @value.respond_to?(method, include_private) || super
    end
  end
end
