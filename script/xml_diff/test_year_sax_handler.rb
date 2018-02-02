# frozen_string_literal: true

require 'ox'

module XmlDiff
  class TestYearSaxHandler < ::Ox::Sax
    attr_reader :elements
    def initialize
      @elements = {}

      @started_elements_with_data = {}
      @started_elements = []
      @test_result = {}
    end

    def current_element
      @started_elements[-1]
    end

    def start_element(name);
      @started_elements << name
      @test_result = {} if name == :'test-result'
    end
    
    def end_element(name)
      if name == :'test-result'
        record_test_result
      end

      if current_element == name
        @started_elements.pop
      else
        raise "Something went wrong"
        exit 1
      end

      @started_elements_with_data.delete(name)
    end

    def attr(name, value)
      started_elements_have_data if value && value.strip.to_s.length > 0
      @test_result[name] = value if @test_result
    end

    def text(value)
      started_elements_have_data if value && value.strip.to_s.length > 0
      @test_result[current_element] = value if @test_result
    end

    def started_elements_have_data
      @started_elements.each do |element|
        @started_elements_with_data[element] = true
      end
    end

    private

    def record_test_result
      test = @test_result[:'test-id']
      year = @test_result[:year]
      @elements[test] ||= Set.new
      @elements[test] << year
      @test_result = nil
    end
  end
end
