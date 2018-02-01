# frozen_string_literal: true

module XmlDiff
  class SaxHandler < ::Ox::Sax
    attr_reader :elements

    def initialize
      @elements = {}
      @started_elements_with_data = {}
      @started_elements = []
    end

    def start_element(name);
      @started_elements << name
    end

    def end_element(name)
      elements[name] ||= 0
      elements[name] += 1 if @started_elements_with_data[name]

      if @started_elements[-1] == name
        @started_elements.pop
      else
        raise "Something went wrong"
        exit 1
      end

      @started_elements_with_data.delete(name)
    end

    def attr(name, value)
      started_elements_have_data if value && value.strip.to_s.length > 0
    end

    def text(value)
      started_elements_have_data if value && value.strip.to_s.length > 0
    end

    def started_elements_have_data
      @started_elements.each do |element|
        @started_elements_with_data[element] = true
      end
    end
  end
end
