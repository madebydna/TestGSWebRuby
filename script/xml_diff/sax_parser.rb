# frozen_string_literal: true

module XmlDiff
  class SaxParser
    def initialize(file:, handler:)
      @file = file
      @handler = handler
    end
    def parse
      Ox.sax_parse(@handler, File.open(@file))
      @handler.elements
    end
  end
end
