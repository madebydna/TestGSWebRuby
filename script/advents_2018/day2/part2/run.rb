if ARGV.length != 1
  puts "We need exactly one parameter. The name of a file."
  exit;
end

filename = ARGV[0]
puts "Going to open '#{filename}'"

values = []

File.open(filename, "r") do |file_handle|
  file_handle.each_line do |value|
    values << value
  end
end

result_indexes = []

values.each_with_index do |v,i|
  v_a = v.split("")
  values.each_with_index do |val,ind|
    val_a = val.split("")
    diff_count = 0
    v_a.each_with_index do |char, index|
      diff_count = diff_count + 1 if char != val_a[index]
    end
    result_indexes << [i,ind] if diff_count == 1
  end
end

v1 = values[result_indexes.first[0]].split("")
v2 = values[result_indexes.first[1]].split("")

result = ''

v1.each_with_index do |v, i|
  result = result + v if v == v2[i]
end

# puts "indexes: " + result_indexes.to_s
# puts "value 1: " + values[result_indexes.first[0]]
# puts "value 1: " + values[result_indexes.first[1]]
puts result