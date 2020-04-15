# frozen_string_literal: trues

# change the file name to file with list of keys one per line that you would like to search the code base for.
# uses find and grep to search in four directories
# ./config/locales/* - this excludes the databases path so as not to get false usage results
# ./app/* - this excludes webpack directory - mostly for speed
# ./client/*
# ./lib/*
#
# run by:
# bundle exec rails runner script/find_characteristic_keys_in_code_base.rb

filename = '/tmp/district_metrics_keys.txt'

# school_metrics_keys.txt
# state_metrics_keys.txt
# district_metrics_keys.txt

results = {}

File.open(filename, "r") do |file_handle|
  file_handle.each_line do |key_name|
    puts key_name
    b = c = d = ''
    key_name = key_name.strip
    find_and_grep_a = "find ./config/locales/* -not -path './config/locales/databases/*' -type f -exec grep -l \"#{key_name}\" {} +"
    find_and_grep_b = "find ./app/* -not -path './app/assets/webpack/*' -type f -exec grep -l \"#{key_name}\" {} +"
    find_and_grep_c = "find ./client/* -type f -exec grep -l \"#{key_name}\" {} +"
    find_and_grep_d = "find ./lib/* -type f -exec grep -l \"#{key_name}\" {} +"

# rubocop:disable Style/CommandLiteral
    # this is a way to short circuit doing all the finds and greps
    a = %x[#{find_and_grep_a}]
    if a == ''
      b = %x[#{find_and_grep_b}]
      if b == ''
        c = %x[#{find_and_grep_c}]
        if c == ''
          d = %x[#{find_and_grep_d}]
        end
      end
    end
# rubocop:enable Style/CommandLiteral
    results[key_name] = a + b + c + d
  end
end

puts '/n/n'
# remove the ones with blank values. They were not found.
m = results.delete_if { |k, v| v.nil? || v == '' }.keys.uniq.join("\n")

# print found results to screen
puts m

# write results to file
f = File.open('/tmp/district_metrics_keys_used.txt', "w")
f.puts m
f.close