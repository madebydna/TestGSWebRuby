#!/usr/bin/env ruby

# frozen_string_literal: true

require 'ox'
require 'set'
require_relative 'sax_handler'
require_relative 'sax_parser'
require_relative 'xml_element_report_generator'

parser = XmlDiff::SaxParser.new(file: ARGV[0], handler: XmlDiff::SaxHandler.new)
report_generator = XmlDiff::XmlElementReportGenerator.new(parser: parser)

# If there is stdin, assume it is the report from another xml file
if STDIN.tty?
  report_generator.print_report
else
  entries_over_threshhold = report_generator.entries_over_threshhold(STDIN, threshold: 0.0)
  entries_over_threshhold.each do |element, percentage_different|
    puts "#{element}\t#{percentage_different}"
  end
  exit 1 if entries_over_threshhold.any?
end

exit 0
