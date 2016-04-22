require_relative '../../../feeds/feed_helpers/feed_helper'
require_relative '../../../feeds/feed_helpers/feed_data_helper'


module FeedBuilders
  class TestRatingFeed
    include FeedHelper
    include FeedDataHelper

    def initialize(attributes = {})
      @state = attributes[:state]
      @school_batches = attributes[:school_batches]
      @district_batches = attributes[:district_batches]
      @feed_type = attributes[:feed_type]
      @feed_file = attributes[:feed_file]
      @root_element = attributes[:root_element]
      @schema = attributes[:schema]
      @ratings_id_for_feed = attributes[:ratings_id_for_feed]
    end

    def generate_feed
      start_time = Time.now
      puts "--- Start Time for generating feed: FeedType: #{@feed_type}  for state #{@state} --- #{Time.now}"
      # xsd_schema ='greatschools-test-rating.xsd'
      #Get State Rating Master Data
      state_ratings_info = get_state_master_data_ratings
      # Translating State Ratings Master  data to XML for State
      @state_ratings_info_for_feed = transpose_state_master_data_ratings_for_feed(state_ratings_info)

      # Write to XML File
      generate_xml_rating_feed
      # system("xmllint --noout --schema #{xsd_schema} #{xmlFile}")
      puts "--- Time taken to generate feed : FeedType: #{@feed_type}  for state #{@state} --- #{Time.at((Time.now-start_time).to_i.abs).utc.strftime "%H:%M:%S:%L"}"
    end

    def process_school_batch_data_for_feed(schools_cache_data)
      schools_data_for_feed = []
        schools_cache_data.try(:each) do |school|
          school_data_for_feed = process_school_data_for_feed(school)
          (schools_data_for_feed << school_data_for_feed).flatten!
        end
      schools_data_for_feed
    end

    def process_school_data_for_feed(school)
      school_data_for_feed = {}
      school_cache = school.school_cache
      school_data = school_cache ? school_cache.ratings : nil
      school_data_ratings = []
      if school_data.present? && school_data.find { |h| h["data_type_id"]== @ratings_id_for_feed }.present?
        school_data_ratings.push(school_data.find { |h| h["data_type_id"]== @ratings_id_for_feed })
        school_data_for_feed = transpose_data_for_xml(school_data_ratings, school, ENTITY_TYPE_SCHOOL)
      else
        puts "No Rating data present for school #{school.id}, school type #{school.type}  and ratings id #{@ratings_id_for_feed} for most recent year"
      end
      school_data_for_feed
    end

    def process_district_batch_data_for_feed(districts_cache_data)
      districts_data_for_feed = []
        districts_cache_data.try(:each) do |district|
          district_data_for_feed = process_district_data_for_feed(district)
          (districts_data_for_feed << district_data_for_feed).flatten!
        end
      districts_data_for_feed
    end

    def process_district_data_for_feed(district)
      district_cache = district.district_cache
      district_data = district_cache ? district_cache.cache_data['ratings'] : nil
      district_data_ratings = []
      if district_data.present? && district_data.find { |h| h["data_type_id"]== @ratings_id_for_feed }.present?
        district_data_ratings.push(district_data.find { |h| h["data_type_id"]== @ratings_id_for_feed })
        district_data_for_feed = transpose_data_for_xml(district_data_ratings, district, ENTITY_TYPE_DISTRICT)
      else
        puts "No Rating data present for district  #{district.id} and ratings id #{@ratings_id_for_feed} for most recent year "
      end
      district_data_for_feed
    end

    def transpose_state_master_data_ratings_for_feed(state_master_data)
      state_level_ratings_config_data = []
      state_master_data.try(:each) do |data|
        config_data = {
            :test_id => transpose_test_id(data[:data_type_id]),
            :year => data[:year],
            :description => transpose_ratings_description(data[:data_type_id])
        }
        state_level_ratings_config_data.push(config_data)
      end
      state_level_ratings_config_data
    end
    def transpose_data_for_xml(ratings_data,entity,entity_level)
      parsed_data_for_xml = []
      ratings_data.try(:each)do |data|
        ratings_data = create_test_rating_hash_for_xml(data, entity, entity_level)
        parsed_data_for_xml.push(ratings_data)
      end
      parsed_data_for_xml
    end

    def create_test_rating_hash_for_xml(data,entity,entity_level)
      test_rating = {:universal_id => transpose_universal_id(entity, entity_level),
                     :entity_level => entity_level.titleize,
                     :test_rating_id => transpose_test_id(data["data_type_id"]),
                     :rating => transpose_ratings(data,entity_level),
                     :url => transpose_url(entity,entity_level)
      }

    end
    def get_state_master_data_ratings
      query_results =TestDataSet.ratings_config_for_state(@state,@ratings_id_for_feed)
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
        # Get district cache data for the batche
        districts_decorated_with_cache_results = get_districts_batch_cache_data(district_batch)
        district_data_for_feed = process_district_batch_data_for_feed(districts_decorated_with_cache_results)
        write_xml_tag(district_data_for_feed, 'test-rating-value', xml)
        puts "district Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

    def write_school_info(xml)
      @school_batches.each_with_index do |school_batch, index|
        puts "school batch Start #{Time.now} for Batch Number #{index+1}"
        # Get school cache data for the batche
        schools_decorated_with_cache_results = get_schools_batch_cache_data(school_batch)
        school_data_for_feed = process_school_batch_data_for_feed(schools_decorated_with_cache_results)
        write_xml_tag(school_data_for_feed, 'test-rating-value', xml)
        puts "school Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

  end
end