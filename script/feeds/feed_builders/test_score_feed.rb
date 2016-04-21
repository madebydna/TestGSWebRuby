require_relative '../../feeds/feed_helpers/feed_helper'

module FeedBuilders
  class TestScoreFeed
    include FeedHelpers

    def initialize(attributes = {})
      @state = attributes[:state]
      @school_batches = attributes[:school_batches]
      @district_batches = attributes[:district_batches]
      @feed_type = attributes[:feed_type]
      @feed_file = attributes[:feed_file]
      @root_element = attributes[:root_element]
      @schema = attributes[:schema]
    end

    def generate_feed
      start_time = Time.now
      puts "--- Start Time for generating feed: FeedType: #{@feed_type}  for state #{@state} --- #{Time.now}"
      # xsd_schema ='greatschools-test.xsd'
      #Generate State Test Master Data
      @state_test_infos_for_feed = get_state_test_master_data
      # Generate District Test Data From Test Tables
      state_test_results = get_state_test_data
      # Translating State Test  data to XML for State
      @state_data_for_feed = transpose_state_data_for_feed(state_test_results)
      # Write to XML File
      generate_xml_test_score_feed
      # system("xmllint --noout --schema #{xsd_schema} #{xmlFile}")
      puts "--- Time taken to generate feed : FeedType: #{@feed_type}  for state #{@state} --- #{Time.at((Time.now-start_time).to_i.abs).utc.strftime "%H:%M:%S:%L"}"

    end

    def get_state_test_master_data
      state_test_infos = []
      state = @state
      TestDescription.where(state: state).find_each do |test|
        data_type_id = test.data_type_id
        test_info = TestDataType.where(:id => data_type_id).first
        test_data_set_info = TestDataSet.on_db(state.downcase.to_sym).
            where(:data_type_id => data_type_id).where(:active => 1).where(:display_target => 'feed').max_by(&:year)
        if test_data_set_info.present?
          state_test_info = {:id => state.upcase + data_type_id.to_s.rjust(5, '0'),
                             :test_id => data_type_id,
                             :test_name => test_info["description"],
                             :test_abbrv => test_info["name"],
                             :scale => test["scale"],
                             :most_recent_year => test_data_set_info["year"],
                             :level_code => test_data_set_info["level_code"],
                             :description => test["description"]
          }
          state_test_infos.push(state_test_info)
        end
      end
      state_test_infos
    end

    def get_state_test_data
      TestDataSet.test_scores_for_state(@state)
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

    def parse_cache_data_for_xml(all_test_score_data, entity, test_id, entity_level)
      parsed_data_for_xml = []
      if all_test_score_data.present?
        complete_test_score_data = all_test_score_data["All"].present? ? all_test_score_data["All"]["grades"] : nil
      end
      if complete_test_score_data.present?
        complete_test_score_data.each do |grade, grade_data|
          grade_data_level = grade_data["level_code"]
          grade_data_level.each do |level, subject_data|
            subject_data.each do |subject, years_data|
              years_data.each do |year, data|

                # Get Band Names from Cache
                bands = data.keys.select { |key| key.ends_with?('band_id') }
                band_names = bands.map { |band| band[0..(band.length-"_band_id".length-1)] }
                band_names << PROFICIENT_AND_ABOVE_BAND

                # Get Data For All Bands
                band_names.each do |band|
                  test_data = create_hash_for_xml(band, data, entity, entity_level, grade, level, subject, test_id, year)
                  parsed_data_for_xml.push(test_data)
                end
              end
            end
          end
        end
      end
      parsed_data_for_xml
    end

    def transpose_school_data_for_feed(schools_cache_data)
      schools_data_for_feed = []
      if schools_cache_data.present?
        schools_cache_data.each do |school|
          school_data_for_feed = {}
          school_cache = school.school_cache
          school_test_data = school_cache ? school_cache.feed_test_scores : nil
          if school_test_data.present?
            school_test_data.each do |test_id, data|
              school_data_for_feed = parse_cache_data_for_xml(data, school, test_id, ENTITY_TYPE_SCHOOL)
            end
          end
          (schools_data_for_feed << school_data_for_feed).flatten!
        end
      end
      schools_data_for_feed
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
        district_data_for_feed = transpose_district_data_for_feed(districts_decorated_with_cache_results)
        write_xml_tag(district_data_for_feed, 'test-result', xml)
        puts "district Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

    def write_school_info(xml)
      @school_batches.each_with_index do |school_batch, index|
        puts "school batch Start #{Time.now} for Batch Number #{index+1}"
        schools_decorated_with_cache_results = get_schools_batch_cache_data(school_batch)
        school_data_for_feed = transpose_school_data_for_feed(schools_decorated_with_cache_results)
        write_xml_tag(school_data_for_feed, 'test-result', xml)
        puts "school Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

    def transpose_district_data_for_feed(districts_cache_data)
      districts_data_for_feed = []
      if districts_cache_data.present?
        districts_cache_data.each do |district|
          district_data_for_feed = {}
          district_cache = district.district_cache
          district_test_data = district_cache ? district_cache.feed_test_scores : nil
          if district_test_data.present?
            district_test_data.each do |test_id, data|
              district_data_for_feed = parse_cache_data_for_xml(data, district, test_id, ENTITY_TYPE_DISTRICT)
            end
          end
          (districts_data_for_feed << district_data_for_feed).flatten!
        end
      end
      districts_data_for_feed
    end

  end
end