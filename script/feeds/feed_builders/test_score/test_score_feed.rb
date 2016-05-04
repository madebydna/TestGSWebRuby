require_relative '../../feed_helpers/feed_helper'
require_relative '../../feed_helpers/feed_data_helper'

require_relative 'test_score_feed_data_reader'

module Feeds
  class TestScoreFeed
    include FeedHelper
    include FeedDataHelper

    def initialize(attributes = {})
      @state = attributes[:state]
      @district_batches = get_district_batches(@state,attributes[:district_ids],attributes[:batch_size])
      @school_batches = get_school_batches(@state,attributes[:school_ids],attributes[:batch_size])
      @feed_file = attributes[:feed_file]
      @root_element = attributes[:root_element]
      @schema = attributes[:schema]
    end

    def generate_feed
      # xsd_schema ='greatschools-test.xsd'
      #Generate State Test Master Data
      @state_test_infos_for_feed = Feeds::TestScoreFeedDataReader.new({state: @state}).get_master_data
      # Generate District Test Data From Test Tables
      state_test_results = Feeds::TestScoreFeedDataReader.new({state: @state}).get_state_data
      # Translating State Test  data to XML for State
      @state_data_for_feed = transpose_state_data_for_feed(state_test_results)
      # Write to XML File
      generate_xml_test_score_feed
      # system("xmllint --noout --schema #{xsd_schema} #{xmlFile}")
    end

    def transpose_state_data_for_feed(state_test_data)
      state_level_test_data = []
      proficiency_bands = Hash[TestProficiencyBand.all.map { |pb| [pb.id, pb] }]
      test_data_subjects = Hash[TestDataSubject.all.map { |o| [o.id, o] }]
      state_test_data.each do |data|
        band = proficiency_bands[data["proficiency_band_id"]].present? ? proficiency_bands[data["proficiency_band_id"]].name : nil
        entity_level = ENTITY_TYPE_STATE
        grade = data["grade_name"]
        year = data["year"]
        level = data["level_code"]
        test_id =data["data_type_id"]
        subject = test_data_subjects[data.subject_id].present? ? test_data_subjects[data.subject_id].name : ''
        test_data = create_hash_for_xml(band, data, nil, entity_level, grade, level, subject, test_id, year)
        state_level_test_data.push(test_data)
      end
      state_level_test_data
    end

    def create_hash_for_xml(band, data, entity = nil, entity_level, grade, level, subject, test_id, year)
      test_data = {:universal_id => transpose_universal_id(entity, entity_level),
                   :entity_level => entity_level.titleize,
                   :test_id => transpose_test_id(test_id),
                   :year => year,
                   :subject_name => subject,
                   :grade_name => grade,
                   :level_code_name => level,
                   :score => transpose_test_score(band, data, entity_level),
                   :proficiency_band_id => transpose_band_id(band, data, entity_level),
                   :proficiency_band_name => transpose_band_name(band),
                   :number_tested => transpose_number_tested(data)
      }
    end

    def transpose_data_for_xml(all_test_score_data, entity, test_id, entity_level)
      parsed_data_for_xml = []
      complete_test_score_data_for_breakdown_all = all_test_score_data.present? && all_test_score_data["All"].present? ? all_test_score_data["All"]["grades"] : nil
        complete_test_score_data_for_breakdown_all.try(:each) do |grade, grade_data|
           grade_data_for_all_levels = grade_data["level_code"]
                  grade_data_for_all_levels.try(:each) do |level, subject_data|
                    subject_data.try(:each) do |subject, years_data|
                      years_data.try(:each) do |year, data|
                        # Get Band Names from Cache
                        band_names = get_band_names(data)
                        # Get Data For All Bands
                        band_names.try(:each) do |band|
                          test_data = create_hash_for_xml(band, data, entity, entity_level, grade, level, subject, test_id, year)
                          parsed_data_for_xml.push(test_data)
                end
              end
            end
          end
      end
      parsed_data_for_xml
    end

    def get_band_names(data)
      bands = data.keys.select { |key| key.ends_with?('band_id') }
      band_names = bands.map { |band| band[0..(band.length-"_band_id".length-1)] }
      band_names << PROFICIENT_AND_ABOVE_BAND
      band_names
    end

    def transpose_schools_data_for_feed(schools_cache_data)
      schools_data_for_feed = []
        schools_cache_data.try(:each) do |school|
          school_data_for_feed = transpose_school(school)
          (schools_data_for_feed << school_data_for_feed).flatten!
        end
      schools_data_for_feed
    end

    def transpose_school(school)
      school_data_for_feed = {}
      school_test_data = Feeds::TestScoreFeedDataReader.new({school: school}).get_school_data
      school_test_data.try(:each)do |test_id, data|
          school_data_for_feed = transpose_data_for_xml(data, school, test_id, ENTITY_TYPE_SCHOOL)
      end
      school_data_for_feed
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
        district_data_for_feed = transpose_districts_data_for_feed(districts_decorated_with_cache_results)
        write_xml_tag(district_data_for_feed, 'test-result', xml)
        puts "district Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

    def write_school_info(xml)
      @school_batches.each_with_index do |school_batch, index|
        puts "school batch Start #{Time.now} for Batch Number #{index+1}"
        schools_decorated_with_cache_results = get_schools_batch_cache_data(school_batch)
        school_data_for_feed = transpose_schools_data_for_feed(schools_decorated_with_cache_results)
        write_xml_tag(school_data_for_feed, 'test-result', xml)
        puts "school Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

    def transpose_districts_data_for_feed(districts_cache_data)
      districts_data_for_feed = []
        districts_cache_data.try(:each) do |district|
          district_data_for_feed = transpose_district(district)
          (districts_data_for_feed << district_data_for_feed).flatten!
        end
      districts_data_for_feed
    end

    def transpose_district(district)
      district_data_for_feed = {}
      district_test_data = Feeds::TestScoreFeedDataReader.new({district: district}).get_district_data
        district_test_data.try(:each) do |test_id, data|
          district_data_for_feed = transpose_data_for_xml(data, district, test_id, ENTITY_TYPE_DISTRICT)
        end
      district_data_for_feed
    end
  end
end