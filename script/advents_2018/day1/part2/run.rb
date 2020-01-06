if ARGV.length != 1
  puts "We need exactly one parameter. The name of a file."
  exit;
end

filename = ARGV[0]
puts "Going to open '#{filename}'"

values = []

File.open(filename, "r") do |file_handle|
  file_handle.each_line do |value|
    values << value.to_i
  end
end

counter = 0
default = 0
answers = []
results = []

while answers.count < 1 and counter < 1000 do
  values.each do |v|
    default = default + v
    results << default
  end
  r = results.group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first)
  answers << r if r.any?
  counter = counter + 1
end

indexes = []
answers.first.each do |a|
  indexes << results.each_index.select{|i| results[i] == a}[1]
end
ans = results[indexes.min]
puts ans