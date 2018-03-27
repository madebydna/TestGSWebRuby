#! /usr/bin/env ruby

# frozen_string_literal: true

first = ARGV[0].to_f
second = ARGV[1].to_f
threshold = ARGV[2].to_f
percent = ARGV[3] == 'true'

diff = second - first

if percent
  percentage = diff / first * 100.0

  if percentage.abs > threshold
    if percentage > threshold
      puts "increased by #{percentage.round(2)}%"
    else
      puts "decreased by #{percentage.abs.round(2)}%"
    end
  end
else
  if diff.abs > threshold
    if diff > threshold
      puts "increased by #{diff}"
    else
      puts "decreased by #{diff.abs}"
    end
  end
end
