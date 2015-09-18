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
  text = text.force_encoding('windows-1252').encode('utf-8') rescue text
  text = text.gsub('\n', '').strip
  text.gsub!(/\n/, '')
  text.gsub!(/\r/, '')
  text.gsub!(/([\{\[,])\s*(\w+)\s?:/) { "#{$1}\"#{$2}\":" }
  text.gsub!('\\\\', '\\')
  text.gsub!(/,( )+\]/, ']')
  text.gsub!('",}', '"}')
  text.gsub!(/( )+/, ' ')

  if text[0] == '{' && text[-1] == '}'
    begin
      # Make legacy JSON blobs actually be valid JSON
      hash = JSON.parse(text)
      puts values_from_hash(hash) if hash.is_a?(Hash)
    rescue Exception => e
      # puts text
    end
  else
    puts text
  end
end
