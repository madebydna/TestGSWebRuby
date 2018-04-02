#! /usr/bin/env ruby

# frozen_string_literal: true

num_groups = ARGV[0].to_i
this_group = ARGV[1].to_i

specs = Dir.glob("spec/**/*_spec.rb")
specs = specs.reject { |s| s.include?("features/") || s.include?("qa/") }

results = specs.each_slice(num_groups).to_a.reduce(&:zip).flatten.compact.each_slice(specs.size/num_groups).to_a[this_group-1]

puts results.join(' ') if results

