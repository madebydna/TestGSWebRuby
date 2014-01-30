#!/usr/bin/env ruby

require 'mysql2'
require "net/http"
require "uri"

require 'active_support/inflector'
require '../config/initializers/extensions/string.rb'
require "../app/helpers/url_helper.rb"
require "../lib/states.rb"
require 'active_support/core_ext/object/blank'

include UrlHelper

client = Mysql2::Client.new(host: 'omega.greatschools.org', username: "service", password: 'service')

id_results = client.query("select school_id from _mi.school_metadata where meta_key = 'collection_id' and meta_value = '1'")
ids = id_results.map{ |row| row['school_id'] }

query = "select * from _mi.school where id in (#{ids.join ','}) and active = 1"
results = client.query(query)

count_non_200 = 0

# Iterate the results
results.each do |row|
    school_name = row['name']
    school_id = row['id']
    school_city = row['city']
    school_state = States.state_name row['state'] 
    level_code = row['level_code']

    state_param = gs_legacy_url_encode(school_state)
    city_param = gs_legacy_url_encode(school_city)
    id_param = school_id
    name_param = encode_school_name(school_name)


    if level_code == 'p'
        canonical_school_overview_path = "/#{state_param}/#{city_param}/preschools/#{name_param}/#{id_param}/"
    else
        canonical_school_overview_path = "/#{state_param}/#{city_param}/#{id_param}-#{name_param}/"
    end
    canonical_school_overview_url = "http://omega.greatschools.org#{canonical_school_overview_path}"

    http = Net::HTTP.new('greatschools.org', 80)
    request = Net::HTTP::Get.new(canonical_school_overview_url)
    response = http.request(request)
    response_code = response.code.to_i

    if response_code != 200
        puts "Got response code #{response_code} for url #{canonical_school_overview_url}"
        count_non_200 += 1
    end
end

puts "Total number of schools with non-200 response code: #{count_non_200}"
