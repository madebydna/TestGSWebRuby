#!/usr/bin/env ruby
require 'json'

def values_from_hash(hash_or_array)
  array = hash_or_array.is_a?(Hash) ? hash_or_array.values : [*hash_or_array]

  array.inject([]) do |result, value|
    case value
      when Hash then result + values_from_hash(value)
      when Array then result + values_from_hash(value)
      else
        result << value
    end
  end
end


STDIN.to_a.each do |text|
  begin
    # Make legacy JSON blobs actually be valid JSON
    text.gsub!(/\n/, '')
    text.gsub!(/\r/, '')
    text.gsub!(/\s(\w+)\:/) { |str| "\"#{str[1..-2]}\":" }
    hash = JSON.parse(text)
  rescue Exception => e
    next
  end

  # flat_hash(hash).values.each do |value|
  #   puts value
  # end
  puts values_from_hash(hash) if hash.is_a?(Hash)
end
