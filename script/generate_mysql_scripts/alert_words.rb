# frozen_string_literal: true

if ARGV.length != 1
  puts "We need exactly one parameter. The name of a file."
  exit;
end

filename = ARGV[0]
puts "Going to open '#{filename}'"

default = 0

output = File.open('output.sql', "w")

File.open(filename, "r") do |file_handle|
  file_handle.each_line do |value|
    array = value.split(',')
    output.write("Insert into community.alert_words (word, really_bad) values('#{array[0].strip}',#{array[1].strip})\n")
  end
end

puts default