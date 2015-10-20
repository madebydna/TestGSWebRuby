#!/usr/bin/env ruby
require 'json'

# Usage examples:
# ./script/http_archive_analyzer.rb /tmp/www.greatschools.org.151019_NE_175T.json bytesOut true
# ./script/http_archive_analyzer.rb /tmp/www.greatschools.org.151019_NE_175T.json download_ms false

class HttpArchiveAnalyzer

  CONFIG = {
    all: {},
    javascript: {
      patterns: /\.js$/
    },
    css: {
      patterns: /\.css$/
    },
    first_party_js: {
      patterns:   /^(http|https):\/\/www\.gscdn\.org.+\.js$/,
      parent: :javascript
    },
    first_party_and_gpt_js: {
      patterns: [ /^(http|https):\/\/www\.gscdn\.org.+\.js$/, /\/gpt.js$/ ],
      parent: :javascript
    },
    third_party_js: {
      parent: :javascript
    },
    first_party_css: {
      patterns: /^(http|https):\/\/www\.gscdn\.org.+\.css$/,
      parent: :css
    },
    third_party_css: {
      parent: :css
    }
  }.freeze

  METRICS = [:bytesOut, :download_ms].freeze
  COLUMN_WIDTH = 100

  attr_accessor :file, :data

  CONFIG.keys.each do |name|
    patterns = *CONFIG.fetch(name, {}).fetch(:patterns, [])
    parent = CONFIG.fetch(name, {}).fetch(:parent, :all)

    if patterns.size > 0
      define_method("#{name}_requests") do
        requests = send("#{parent}_requests")
        requests.select { |r| patterns.any? { |pattern| pattern.match(r['_full_url']) } }
      end
    end

    METRICS.each do |metric|
      define_method("#{name}_#{metric}") do
        send("#{name}_requests").inject(0) { |total, request| total += request["_#{metric}"].to_f }
      end

      define_method("#{name}_#{metric}_report") do |show_detail|
        value = send("#{name}_#{metric}")
        parent_value = parent ? send("#{parent}_#{metric}") : 1
        report_row = proc do |name, parent, value, parent_value|
          puts name.to_s.ljust(40, ' ') + ' | ' + "#{metric} #{value}".ljust(20, ' ') + ' | ' + "Percentage of #{parent}: #{(value.to_f / parent_value.to_f * 100).round(2)}"
        end
        report_row.call(name, parent, value, parent_value)
        if show_detail
          send("#{name}_requests").each do |request|
            report_row.call(request['_url'][-40..-1], name, request['_' + metric.to_s], value)
          end
          puts '=' * COLUMN_WIDTH
        end
      end
    end
  end

  def third_party_js_requests
    javascript_requests - first_party_js_requests
  end

  def third_party_css_requests
    css_requests - first_party_css_requests
  end

  def initialize(filename)
    self.file = File.read(filename)
    self.data = JSON.parse(file)
  end

  METRICS.each do |metric|
    define_method("#{metric}_report") do |show_detail|
      puts "Metric: #{metric}"
      puts '-' * COLUMN_WIDTH
      [:all, :javascript, :first_party_js, :third_party_js, :css, :first_party_css, :third_party_css].each do |item|
        send("#{item}_#{metric}_report", show_detail)
      end
      nil
    end
  end

  def all_requests
    data['log']['entries']
  end
end

if ARGV && ARGV[0] && ARGV[1]
  file_name = ARGV[0]
  report = ARGV[1]
  detail = ARGV[2]
  detail = false if detail == nil
  analyzer = HttpArchiveAnalyzer.new(file_name)
  analyzer.send("#{report}_report", detail)
end