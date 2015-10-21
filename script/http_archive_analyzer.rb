#!/usr/bin/env ruby
require 'json'

# Usage examples:
# ./script/http_archive_analyzer.rb /tmp/www.greatschools.org.151019_NE_175T.json bytesOut true
# ./script/http_archive_analyzer.rb /tmp/www.greatschools.org.151019_NE_175T.json download_ms false

class HttpArchiveAnalyzer

  CONFIG = {
    all: {},
    javascript: {
      content_types: ['application/javascript', 'text/javascript', 'application/x-javascript']
    },
    css: {
      content_types: 'text/css'
    },
    first_party_js: {
      hosts: 'www.gscdn.org',
      parent: :javascript
    },
    first_party_and_gpt_js: {
      hosts: ['www.gscdn.org', 'www.googletagservices.com'],
      parent: :javascript
    },
    third_party_js: {
      parent: :javascript
    },
    first_party_css: {
      hosts: 'www.gscdn.org',
      parent: :css
    },
    third_party_css: {
      parent: :css
    },
    fonts: {
      content_types: ['application/x-font-woff', 'font/woff2']
    },
    images: {
      content_types: /^image/,
    },
    first_party_images: {
      hosts: 'www.gscdn.org',
      parent: :images
    },
    third_party_images: {
      parent: :images
    },
    html: {
      content_types: 'text/html'
    },
    other_content: {
    }
  }.freeze

  METRICS = [:bytesOut, :download_ms, :time].freeze
  COLUMN_WIDTH = 100

  attr_accessor :file, :data

  CONFIG.keys.each do |name|
    config = CONFIG.fetch(name, {})
    parent = config.fetch(:parent, :all)

    define_method("#{name}_requests") do
      urls= *config.fetch(:urls, [])
      content_types = *config.fetch(:content_types, [])
      hosts = *config.fetch(:hosts, [])
      requests = send("#{parent}_requests")
      r = requests.select do |r|
        (urls.size == 0 || urls.any? { |pattern| pattern.match(r['_full_url']) }) &&
        (content_types.size == 0 || content_types.any? { |pattern| pattern.match(r['_contentType']) if r['_contentType'] }) &&
        (hosts.size == 0 || hosts.any? { |pattern| pattern.match(r['_host']) })
      end.extend(MethodsForArrayOfRequests)
    end

    METRICS.each do |metric|
      define_method("#{name}_#{metric}") do
        send("#{name}_requests").sum(metric)
      end

      define_method("#{name}_#{metric}_report") do |detail_for_attribute = nil|
        requests = send("#{name}_requests")
        value = send("#{name}_#{metric}").to_f
        parent_value = parent ? send("#{parent}_#{metric}").to_f : 1
        report_row(name, parent, requests.sum(metric), parent_value)
        if detail_for_attribute
          requests_by_attribute = requests.group_by_attribute(detail_for_attribute)
          requests_by_attribute.extend(MethodsForHashOfRequests)
          requests_by_attribute = requests_by_attribute.sort_by_metric(metric)
          requests_by_attribute.each do |attribute, requests|
            report_row(attribute, name, requests.sum(metric), value)
          end
          puts
        end
      end
    end
  end

  def report_row(label, parent_label, value, parent_value)
    percent_of_parent = (value.to_f / parent_value.to_f * 100).round(2)
    columns = [
      label[0..59].to_s.ljust(60, ' '),
      value.to_s.ljust(10, ' '),
      "% of #{parent_label}: #{percent_of_parent}"
    ]
    puts columns.join(' | ')
  end

  def third_party_js_requests
    (javascript_requests - first_party_js_requests).extend(MethodsForArrayOfRequests)
  end

  def third_party_css_requests
    (css_requests - first_party_css_requests).extend(MethodsForArrayOfRequests)
  end

  def third_party_image_requests
    (image_requests - first_party_image_requests).extend(MethodsForArrayOfRequests)
  end

  def group_by_host_and_content_category
    all_requests.group_by do |request|
      [request['_host'], content_category(request['_contentType'])]
    end
  end

  def content_category(content_type)
    case content_type
      when 'application/javascript', 'text/javascript', 'application/x-javascript'
        'javascript'
      when 'image/png', 'image/gif', 'image/jpeg', 'image/x-icon'
        'images'
      when 'test/css'
        'css'
      when 'text/html'
        'html'
      when 'application/x-font-woff', 'font/woff2'
        'fonts'
      else
        'other_content'
    end
  end

  def initialize(filename)
    self.file = File.read(filename)
    self.data = JSON.parse(file)
  end

  METRICS.each do |metric|
    define_method("#{metric}_report") do |detail_for_attribute = nil|
      puts "Metric: #{metric}"
      puts '-' * COLUMN_WIDTH
      [
        :all,
        :javascript,
        :first_party_js,
        :third_party_js,
        :css,
        :first_party_css,
        :third_party_css,
        :images,
        :first_party_images,
        :third_party_images,
        :fonts,
        :html
      ].each do |item|
        send("#{item}_#{metric}_report", detail_for_attribute)
      end
      nil
    end
  end

  def all_requests
    data['log']['entries'].map { |r| r.extend(MethodsForRequest) }.extend(MethodsForArrayOfRequests)
  end

  module MethodsForArrayOfRequests
    def average(metric)
      sum(metric) / size.to_f
    end
    def sum(metric)
      inject(0.0) do|total, r|
        total += (r.send(metric).to_f || 0).to_f
      end
    end
    def group_by_attribute(attribute)
      hash = group_by do |request|
        request["_#{attribute}"] || request[attribute]
      end
      hash.each do |attribute, values|
        values.extend(MethodsForArrayOfRequests)
      end
      hash
    end
  end

  module MethodsForHashOfRequests
    def sort_by_metric(metric, descending = true)
      array = sort_by do |attribute, requests|
        requests.inject(0.0) { |total, r| total += r.send(metric).to_f }
      end
      if descending
        array.reverse!
      end
      Hash[array]
    end
  end

  module MethodsForRequest
    def method_missing(method, *args)
      send(:fetch, method.to_s, nil) || send(:fetch, "_#{method}", nil)
    end
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