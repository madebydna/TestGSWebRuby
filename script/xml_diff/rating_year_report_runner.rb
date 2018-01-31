#!/usr/bin/env ruby

# frozen_string_literal: true

require 'ox'
require 'set'
require_relative 'rating_year_sax_handler'
require_relative 'sax_parser'
require_relative 'xml_rating_year_report_generator'

parser = XmlDiff::SaxParser.new(io: ARGF, handler: XmlDiff::RatingYearSaxHandler.new)
report_generator = XmlDiff::XmlRatingYearReportGenerator.new(parser: parser)
report_generator.print_report

exit 0
