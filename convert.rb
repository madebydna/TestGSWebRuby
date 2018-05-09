def convert_string_to_int(string)
	neg = 0
	result = 0
	return 0 if string == "0"
	neg = 1 if string[0] == "-"

	string.each_char do |c|
		next if c == "-"
		result *= 10
		result += (c.ord - '0'.ord) % 10
	end

	return (neg == 1)?(-result):result
end


def convert_int_to_string(num)
	neg = 0
	i = 0
	result = ""
	temp = ""
	if num < 0
		neg = 1 
		num = -num
	end
	while (num != 0)
		temp[i] = "#{num%10} + '0'.ord"
		i += 1
		num = num/10
	end
	if neg == 1
		result = "-"
	end
	while (i > 0)
		i -= 1
		result += temp[i]
	end
	return result
end


num = -1234
str = "-542"

#puts convert_string_to_int(str)
puts convert_int_to_string(num)