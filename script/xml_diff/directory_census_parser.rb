#!/usr/bin/env ruby

# frozen_string_literal: true

require 'ox'
require 'mysql2'

# This class iterates over a select group of fields and compares them for discrepancies in the database.
class DirectoryCensusParser < ::Ox::Sax

  attr_reader :state

  def initialize(state)
    @state = state
    @elements = {}
    @started_elements = []
    @directory_info = {}
  end

  def start_element(name)
    @started_elements << name
    @directory_info = {} if name == :school
  end

  def current_element
    @started_elements[-1]
  end

  def end_element(name)
    if name == :school
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
    @directory_info[name] = value if @directory_info
  end

  def text(value)
    @directory_info[current_element] = value if (@directory_info && !@directory_info[current_element].present?)
  end

  private

  def handle_result
    id = @directory_info[:'universal-id']
    @elements[id] = {
        name: @directory_info[:name],
        district_id: @directory_info[:'district-id'],
        street: @directory_info[:street],
        city: @directory_info[:city],
        zipcode: @directory_info[:zip]
      }

    db_id = id[-5,5].gsub(/^0+/,'')

    db_results = School.find_by_state_and_id(state, db_id)

    @elements[id].each do |field,value|
      if value != (db_results[field].to_s)
        puts "discrepancy: -- state: #{state}\tuniversal_id: #{id}\tfield: #{field}\txml val: #{value}\t db val: #{db_results[field].to_s}"
      end
    end

    @directory_info = nil
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
  handler = DirectoryCensusParser.new(state)
  Ox.sax_parse(handler, io)
  system("rm #{xml_path}")
end