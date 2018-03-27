#! /usr/bin/env ruby

# frozen_string_literal: true

require 'json'
require 'optparse'

script_args = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [script_args]"
  opts.on("-c", 'Output as csv') { |b| script_args[:csv] = b }
  opts.on_tail("-h", "--help", "Show this message") { puts opts; exit }
end.parse!

this_script_dir = File.dirname(__FILE__)
root_dir = File.join(this_script_dir, '..', '..')
threshold = 0.05
has_stdin = !STDIN.tty?

files = %w[
  app/assets/webpack/commons-blocking-bundle*js
  app/assets/webpack/commons-bundle*js
  app/assets/webpack/school-profiles-bundle*js
  public/assets/post_load*css.gz
  public/assets/application*css.gz
]

sizes = files.each_with_object({}) do |file, hash|
  full_path = File.join(root_dir, file)
  files = Dir.glob(full_path)
  size = File.size(files.last) rescue nil
  hash[file] = size 
end

if has_stdin
  old_sizes = JSON.parse(STDIN.read.chomp) rescue {}
  files.each do |file|
    basename = File.basename(file)
    next unless old_sizes[file]
    old_size = old_sizes[file].to_f
    new_size = sizes[file].to_f
    percent_diff = (old_size - new_size).abs / old_size
    if percent_diff > threshold
      if new_size > old_size
        message = "#{basename} increased by "
      else
        message = "#{basename} decreased by "
      end
      message << (percent_diff * 100.0).round.to_s << '%'
      puts message
    end
  end
elsif script_args[:csv]
  puts sizes.keys.map { |f| File.basename(f) }.join(',')
  puts sizes.values.join(',')
else
  puts JSON.pretty_unparse(sizes)
end
