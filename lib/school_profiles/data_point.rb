module SchoolProfiles
  class DataPoint
    module Formatters
      def self.round(value)
        value.respond_to?(:round) ? value.round : value
      end

      def self.round_unless_less_than_1(value)
        if ((value.to_i.to_s == value.to_s) || (value.to_f.to_s == value.to_s))
          value = value.to_f
        end

        if value.is_a?(Numeric) && value < 1
          '<1'
        else
          value.respond_to?(:round) ? value.round : value
        end
      end

      def self.percent(value)
        "#{value}%"
      end

      def self.to_f(value)
        value.to_f
      end

      def self.invert_using_one_hundred(value)
        100.to_f - value
      end

      def self.dollars(value)
        ActiveSupport::NumberHelper.number_to_currency(value, precision:0)
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

    def float_value
      return nil if value.nil?
      value.to_s.scan(/[0-9.]+/).first.to_f
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
