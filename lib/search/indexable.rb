# frozen_string_literal: true

module Search
  module Indexable
    def self.type
      raise 'Not implemented'
    end

    def type
      self.class.type
    end

    def add_field(name, value, type: nil, stored: false, indexed: true)
      return if value.nil?
      @_fields ||= {}
      field = Search::SolrIndexer::make_field(name, value, type: type, stored: stored, indexed: indexed)
      @_fields[field] = value
    end

    def build
      add_field(:id, type_and_unique_key)
      add_field(:type, self.type)
    end

    def any_fields_added?
      field_values.length > 2 # number of default fields added in build
    end

    def field_values
      @_field_values ||= begin
        build
        @_fields
      end
    end

    def type_and_unique_key
      "#{type} #{unique_key}"
    end

    def unique_key
      raise 'Not implemented'
    end

    def id
      unique_key
    end
  end
end
