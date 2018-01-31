#!/usr/bin/env ruby

# frozen_string_literal: true

require 'ox'
require 'set'
require_relative 'test_year_sax_handler'
require_relative 'sax_parser'
require_relative 'xml_test_year_report_generator'

parser = XmlDiff::SaxParser.new(io: ARGF, handler: XmlDiff::TestYearSaxHandler.new)
report_generator = XmlDiff::XmlTestYearReportGenerator.new(parser: parser)
report_generator.print_report

exit 0
