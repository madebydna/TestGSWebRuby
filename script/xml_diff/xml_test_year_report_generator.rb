# frozen_string_literal: true

module XmlDiff
  class XmlTestYearReportGenerator
    def initialize(parser:)
      @parser = parser
    end

    def test_years_array
      @parser.parse.each_with_object([]) do |(k,v), memo|
        ary = v.to_a.map { |year| "#{k} #{year}" }
        memo.concat(ary)
      end
    end

    def print_report
      puts test_years_array
    end
  end
end
