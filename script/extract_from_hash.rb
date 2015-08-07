#!/usr/bin/env ruby
require 'json'

scope = ARGV[0]

keys = scope.split '.'

STDIN.to_a.each do |text|
  begin
    json = JSON.parse(text)
  rescue Exception => e
    puts text
    next
  end

  value = json
  keys.each do |key|
    value = value.fetch(key, {})
  end

  puts value.to_s
end