require_relative '../../feed_helpers/feed_helper'
require_relative '../../feed_helpers/feed_data_helper'

require_relative 'test_score_feed_data_reader'
require_relative 'test_score_feed_transformer'


module Feeds
  class TestScoreFeed
    include Feeds::FeedHelper
    include Feeds::FeedDataHelper
    include Feeds::TestScoreFeedDataReader
    include Feeds::TestScoreFeedTransformer

    def initialize(attributes = {})
      @state = attributes[:state]
      @district_batches = get_district_batches(@state,attributes[:district_ids],attributes[:batch_size])
      @school_batches = get_school_batches(@state,attributes[:school_ids],attributes[:batch_size])
      @feed_file = attributes[:feed_file]
      @root_element = attributes[:root_element]
      @schema = attributes[:schema]
      @data_type = attributes[:data_type]
    end

    def generate_feed
      # xsd_schema ='greatschools-test.xsd'
      #Generate State Test Master Data
      @state_test_infos_for_feed = get_test_score_state_master_data(@state)
      # Generate District Test Data From Test Tables
      state_test_results = get_state_test_score_data(@state,@data_type)
      # Translating State Test  data to XML for State
      @state_data_for_feed = transpose_state_data_for_feed(@state,state_test_results,@data_type)
      # Write to XML File
      generate_xml_test_score_feed
      # system("xmllint --noout --schema #{xsd_schema} #{xmlFile}")
    end

    def generate_xml_test_score_feed
      File.open(@feed_file, 'w') { |f|
        xml = Builder::XmlMarkup.new(:target => f, :indent => 1)
        xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
        xml.tag!(@root_element,
                 {'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                  :'xsi:noNamespaceSchemaLocation' => @schema}) do
                            # Generates test info tag
                            write_xml_tag(@state_test_infos_for_feed, 'test', xml)
                            # Generate state test data tag
                            write_xml_tag(@state_data_for_feed, 'test-result', xml)
                            #Generate School Info
                            write_school_info(xml)
                            #Generate District Info
                            write_district_info(xml)

                          end
                  }
    end

    def write_district_info(xml)
      @district_batches.each_with_index do |district_batch, index|
        puts "district batch Start #{Time.now} for Batch Number #{index+1}"
        districts_decorated_with_cache_results = get_districts_batch_cache_data(district_batch)
        district_data_for_feed = process_district_batch_data_for_feed(districts_decorated_with_cache_results)
        write_xml_tag(district_data_for_feed, 'test-result', xml)
        puts "district Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

    def write_school_info(xml)
      @school_batches.each_with_index do |school_batch, index|
        puts "school batch Start #{Time.now} for Batch Number #{index+1}"
        schools_decorated_with_cache_results = get_schools_batch_cache_data(school_batch)
        school_data_for_feed = process_school_batch_data_for_feed(schools_decorated_with_cache_results)
        write_xml_tag(school_data_for_feed, 'test-result', xml)
        puts "school Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

    def process_school_batch_data_for_feed(schools_cache_data)
      schools_cache_data.try(:map) { |school| process_school_data_for_feed(school) }.flatten
    end

    def process_district_batch_data_for_feed(districts_cache_data)
      districts_cache_data.try(:map) { |district| process_district_data_for_feed(district) }.flatten
    end

    def process_school_data_for_feed(school)
      school_data_for_feed = {}
      school_test_data = get_school_test_score_data(school)
      school_test_data.try(:each)do |test_id, data|
        school_data_for_feed = transpose_data_for_xml(@state,data, school, test_id, ENTITY_TYPE_SCHOOL,@data_type)
      end
      school_data_for_feed
    end

    def process_district_data_for_feed(district)
      district_data_for_feed = {}
      district_test_data = get_district_test_score_data(district)
        district_test_data.try(:each) do |test_id, data|
          district_data_for_feed = transpose_data_for_xml(@state,data, district, test_id, ENTITY_TYPE_DISTRICT,@data_type)
        end
      district_data_for_feed
    end
  end
end
