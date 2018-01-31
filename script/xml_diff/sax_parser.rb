# frozen_string_literal: true

module XmlDiff
  class SaxParser
    def initialize(file:nil, handler:, io: nil)
      @file = file
      @handler = handler
      @io = io
    end

    def io
      @io ||= File.open(@file)
    end

    def parse
      Ox.sax_parse(@handler, io)
      @handler.elements
    end
  end
end
