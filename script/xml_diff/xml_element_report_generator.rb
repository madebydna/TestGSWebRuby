# frozen_string_literal: true

module XmlDiff
  class XmlElementReportGenerator
    def initialize(parser:)
      @parser = parser
    end

    def print_report
      @parser.parse.each { |name, count| puts "#{name}\t#{count}" }
    end

    def entries_over_threshhold(other_report, threshold: 0.1)
      other_hash = XmlElementReportGenerator.hash_from_report(other_report)
      compare(other_hash).select { |element, difference| difference > threshold }
    end

    def compare(other_hash)
      @parser.parse.each_with_object({}) do |(name, count), memo|
        other_count = other_hash[name]
        if other_count
          memo[name] = (other_count - count).abs.to_f / (other_count.nonzero? || 1)
        else
          memo[name] = 1
        end
      end
    end

    def self.hash_from_report(report)
      report.each_line.each_with_object({}) do |line, memo|
        element, count = line.strip.split("\t")
        memo[element.to_sym] = count.to_f
      end
    end
  end
end
