# frozen_string_literal: true

module Search
  module Indexable
    def self.type
      raise 'Not implemented'
    end

    def type
      self.class.type
    end

    def to_h
      return {} unless field_values.present?
      {
        id: type_and_unique_key,
        type: self.type,
      }.merge(field_values)
    end

    def type_and_unique_key
      "#{type} #{unique_key}"
    end

    def field_values
      raise 'Not implemented'
    end

    def unique_key
      raise 'Not implemented'
    end

    def id
      unique_key
    end
  end
end
