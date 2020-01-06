if ARGV.length != 1
  puts "We need exactly one parameter. The name of a file."
  exit;
end

filename = ARGV[0]
puts "Going to open '#{filename}'"

two_letters = 0
three_letters = 0

alphabet = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)

File.open(filename, "r") do |file_handle|
  file_handle.each_line do |value|
    one_two_add = true
    one_three_add = true
    alphabet.each do |letter|
      c = value.count(letter)
      if c == 2 && one_two_add
        one_two_add = false
        two_letters = two_letters + 1
      end
      if c == 3 && one_three_add
        one_three_add = false
        three_letters = three_letters + 1
      end
    end
  end
end

puts "two_letters #{two_letters}"
puts "three_letters #{three_letters}"
puts "total #{three_letters * two_letters}"