#!/usr/bin/env ruby

# frozen_string_literal: true

require 'ox'
require 'mysql2'
require 'zip'

class CensusParser < ::Ox::Sax

  attr_reader :state

  CENSUS_DATA_TYPE_ID = 17

  def initialize(state)
    @state = state
    @started_elements = []
    @census_info = {}
  end

  def start_element(name)
    @started_elements << name
    @census_info = {} if name == :enrollment
  end

  def current_element
    @started_elements[-1]
  end

  def end_element(name)
    if name == :enrollment
      handle_result
    end

    if current_element == name
      @started_elements.pop
    else
      raise "Something went wrong"
      exit 1
    end

  end

  def attr(name, value)
    @census_info[name] = value if @census_info
  end

  def text(value)
    @census_info[current_element] = value if (@census_info && !@census_info[current_element].present?)
  end

  private

  def handle_result
    id = @census_info[:'universal-id']
    puts id
    
    if id.length == 7
      db_id = id[-5,5].gsub(/^0+/,'')
      xml_value = @census_info[:enrollment]
      db_value = census_value(state, db_id)

      if xml_value != db_value.to_s
          puts "discrepancy: -- state: #{state}\tuniversal_id: #{id}\txml_val: #{xml_value}\t db_val: #{db_value.to_s}"
        end
      end
    
    @census_info = nil
  end

  def census_query(state, id)
    CensusDataSetQuery.new(state)
        .with_data_types([CENSUS_DATA_TYPE_ID])
        .with_school_values(id)
  end

  def census_value(state, id)
    results = CensusDataResults.new(census_query(state, id).to_a)
                  .filter_to_max_year_per_data_type!
                  .results

    results.select{ |r| r.grade.nil? }.first.school_value.to_i
  end

end

states = States.abbreviations
states.each do |state|
  zipped_path = "/home/feeds/feeds/greatschools/local-greatschools-feed-#{state.upcase}.zip"
  xml_path = "/tmp/local-greatschools-feed-#{state.upcase}.xml"
  puts "Working on #{state}"
  system("rm #{xml_path} 2> /dev/null")
  system("unzip #{zipped_path} -d /tmp/")
  io = File.open("#{xml_path}")
  handler = CensusParser.new(state)
  Ox.sax_parse(handler, io)
  system("rm #{xml_path}")
end