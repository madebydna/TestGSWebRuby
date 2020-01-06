if ARGV.length != 1
  puts "We need exactly one parameter. The name of a file."
  exit;
end

filename = ARGV[0]
puts "Going to open '#{filename}'"

default = 0

File.open(filename, "r") do |file_handle|
  file_handle.each_line do |value|
    default = default + value.to_i
  end
end

puts default