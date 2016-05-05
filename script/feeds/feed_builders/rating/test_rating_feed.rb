require_relative '../../feed_helpers/feed_helper'
require_relative '../../feed_helpers/feed_data_helper'
require_relative 'test_rating_feed_data_reader'
require_relative 'test_rating_feed_transformer'


module Feeds
  class TestRatingFeed
    include Feeds::FeedHelper
    include Feeds::FeedDataHelper
    include Feeds::TestRatingFeedDataReader
    include Feeds::TestRatingFeedTransformer


    def initialize(attributes = {})
      @state = attributes[:state]
      @district_batches = get_district_batches(@state,attributes[:district_ids],attributes[:batch_size])
      @school_batches = get_school_batches(@state,attributes[:school_ids],attributes[:batch_size])
      @feed_file = attributes[:feed_file]
      @root_element = attributes[:root_element]
      @schema = attributes[:schema]
      @ratings_id_for_feed = attributes[:ratings_id_for_feed]
    end

    def generate_feed
       # xsd_schema ='greatschools-test-rating.xsd'
      #Get State Rating Master Data
      state_ratings_info =get_ratings_master_data(@state, @ratings_id_for_feed)
      # Translating State Ratings Master  data to XML for State
      state_name= States.state_name(@state).titleize
      @state_ratings_info_for_feed = transpose_state_master_data_ratings_for_feed(state_ratings_info,state_name)

      # Write to XML File
      generate_xml_rating_feed
      # system("xmllint --noout --schema #{xsd_schema} #{xmlFile}")
    end

    def generate_xml_rating_feed
      root_element = @root_element
      File.open(@feed_file, 'w') { |f|
        xml = Builder::XmlMarkup.new(:target => f, :indent => 1)
        xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
        xml.tag!(root_element,
                 {'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
                  :'xsi:noNamespaceSchemaLocation' => @schema}) do

          # Generates test info tag
          write_xml_tag(@state_ratings_info_for_feed, 'test-rating', xml)
          write_school_info(xml)
          write_district_info(xml)
        end
      }

    end

    def write_district_info(xml)
      @district_batches.each_with_index do |district_batch, index|
        puts "district batch Start #{Time.now} for Batch Number #{index+1}"
        districts_decorated_with_cache_results = get_districts_batch_cache_data(district_batch)
        district_data_for_feed = process_district_batch_data_for_feed(districts_decorated_with_cache_results, @ratings_id_for_feed)
        write_xml_tag(district_data_for_feed, 'test-rating-value', xml)
        puts "district Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

    def write_school_info(xml)
      @school_batches.each_with_index do |school_batch, index|
        puts "school batch Start #{Time.now} for Batch Number #{index+1}"
        schools_decorated_with_cache_results = get_schools_batch_cache_data(school_batch)
        school_data_for_feed = process_school_batch_data_for_feed(schools_decorated_with_cache_results, @ratings_id_for_feed)
        write_xml_tag(school_data_for_feed, 'test-rating-value', xml)
        puts "school Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

    def process_school_batch_data_for_feed(schools_cache_data, ratings_id_for_feed)
      schools_cache_data.try(:map) {|school| process_school_data_for_feed(school, ratings_id_for_feed) }.flatten
    end

    def process_district_batch_data_for_feed(districts_cache_data, ratings_id_for_feed)
      districts_cache_data.try(:map) {|district| process_district_data_for_feed(district, ratings_id_for_feed) }.flatten
    end

    def process_school_data_for_feed(school, ratings_id_for_feed)
      school_rating_id_cache_data = get_school_data_for_ratings(school,ratings_id_for_feed)
      school_data_for_feed = transpose_data_for_xml(school_rating_id_cache_data, school, ENTITY_TYPE_SCHOOL)
      school_data_for_feed
    end

    def process_district_data_for_feed(district, ratings_id_for_feed)
      district_rating_id_cache_data =  get_district_data_for_ratings(district, ratings_id_for_feed)
      district_data_for_feed= transpose_data_for_xml(district_rating_id_cache_data, district, ENTITY_TYPE_DISTRICT)
      district_data_for_feed
    end
  end
end