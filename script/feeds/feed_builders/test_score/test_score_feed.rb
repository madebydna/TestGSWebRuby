require_relative '../../feed_helpers/feed_helper'
require_relative '../../feed_helpers/feed_data_helper'

require_relative 'test_score_feed_data_reader'
require_relative 'test_score_feed_transformer'
require_relative '../../feed_config/feed_constants'

module Feeds
  class TestScoreFeed
    include Feeds::FeedHelper
    include Feeds::FeedDataHelper
    include Feeds::TestScoreFeedDataReader
    include Feeds::FeedConstants

    attr_reader :state, :data_type

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
      # @state_test_infos_for_feed = get_test_score_state_master_data(@state)

      @state_data_for_feed = state_data_stuff.xml_data

      # Write to XML File
      generate_xml_test_score_feed
      # system("xmllint --noout --schema #{xsd_schema} #{xmlFile}")
    end

    def state_data_stuff
      @_state_data_stuff ||= Feeds::StateDataStuff.new(state, data_type)
    end

    def generate_xml_test_score_feed
      File.open(@feed_file, 'w') { |f|
        xml = Builder::XmlMarkup.new(:target => f, :indent => 1)
        xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
        xml.tag!(@root_element,
                 {'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
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
        Feeds::FeedLog.log.debug "District batch Start #{Time.now} for Batch Number #{index+1}"
        districts_decorated_with_cache_results = get_districts_batch_cache_data(district_batch)
        district_data_for_feed = process_district_batch_data_for_feed(districts_decorated_with_cache_results)
        write_xml_tag(district_data_for_feed, 'test-result', xml)
        Feeds::FeedLog.log.debug "District Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

    def write_school_info(xml)
      @school_batches.each_with_index do |school_batch, index|
        Feeds::FeedLog.log.debug "School batch Start #{Time.now} for Batch Number #{index+1}"
        schools_decorated_with_cache_results = get_schools_batch_cache_data(school_batch)
        school_data_for_feed = process_school_batch_data_for_feed(schools_decorated_with_cache_results)
        write_xml_tag(school_data_for_feed, 'test-result', xml)
        Feeds::FeedLog.log.debug "School Batch end #{Time.now} for Batch Number #{index+1}"
      end
    end

    def process_school_batch_data_for_feed(schools_cache_data)
      schools_cache_data.try(:map) { |school| process_school_data_for_feed(school) }.flatten
    end

    def process_district_batch_data_for_feed(districts_cache_data)
      districts_cache_data.try(:map) { |district| process_district_data_for_feed(district) }.flatten
    end

    def process_school_data_for_feed(school)
      school_test_data = get_school_test_score_data(school)
      school_test_data.try(:map)do |test_id, data|
       transpose_data_for_xml(data, school, test_id, ENTITY_TYPE_SCHOOL,@data_type)
      end
    end

    def process_district_data_for_feed(district)
      district_test_data = get_district_test_score_data(district)
        district_test_data.try(:map) do |test_id, data|
           transpose_data_for_xml(data, district, test_id, ENTITY_TYPE_DISTRICT,@data_type)
        end
    end

    @@proficiency_bands = Hash[TestProficiencyBand.all.map { |pb| [pb.id, pb] }]
    @@test_data_subjects = Hash[TestDataSubject.all.map { |o| [o.id, o] }]
    @@test_data_breakdowns = Hash[TestDataBreakdown.all.map { |bd| [bd.id, bd] }]
    @@test_data_breakdowns_name_mapping = Hash[TestDataBreakdown.all.map { |bd| [bd.name, bd] }]



    def transpose_data_for_xml(all_test_score_data, entity, test_id, entity_level,data_type)
      parsed_data_for_xml = []
      test_score_data = all_test_score_data.present? &&  data_type == WITH_NO_BREAKDOWN ? all_test_score_data.try(:slice, 'All') : all_test_score_data
      test_score_data.try(:each) do |breakdown,breakdown_data|
        breakdown_data['grades'].try(:each) do |grade, grade_data|
          grade_data['level_code'].try(:each) do |level, subject_data|
            subject_data.try(:each) do |subject, years_data|
              years_data.try(:each) do |year, data|
                # Get Band Names from Cache
                band_names = get_band_names(data)
                # Get Data For All Bands
                band_names.try(:each) do |band|
                  test_data = create_hash_for_xml(band, data, entity, entity_level, grade, level, subject, test_id, year,data_type,nil,breakdown)
                  parsed_data_for_xml.push(test_data)
                end
              end
            end
          end
        end
      end
      parsed_data_for_xml
    end

    def create_hash_for_xml(band, data, entity = nil, entity_level, grade, level, subject, test_id, year, data_type,breakdown_id, breakdown_name)
      test_data = {:universal_id => transpose_universal_id(state,entity, entity_level),
                   :test_id => transpose_test_id(state,test_id),
                   # :entity_level => entity_level.titleize,
                   :year => year,
                   :subject_name => subject,
                   :grade_name => grade,
                   :level_code_name => level,
                   :score => transpose_test_score(band, data, entity_level),
                   :proficiency_band_id => transpose_band_id(band, data, entity_level),
                   :proficiency_band_name => transpose_band_name(band)
      }
      additional_data_for_subgroup = {:breakdown_id => transpose_breakdown_id(breakdown_id,breakdown_name,@@test_data_breakdowns_name_mapping),
                                      :breakdown_name => breakdown_name
      }
      number_tested = { :number_tested => transpose_number_tested(data,band,entity_level)
      }
      data_type == WITH_ALL_BREAKDOWN ? test_data.merge!(additional_data_for_subgroup).merge!(number_tested) : test_data.merge!(number_tested)
    end

    def transpose_breakdown_id(breakdown_id,breakdown_name,test_data_breakdowns)
      breakdown_name = breakdown_name == 'All' ? 'All students' : breakdown_name
      breakdown_id.present?  ?  breakdown_id : test_data_breakdowns[breakdown_name].try(:id)
    end


    def transpose_test_score(band, data,entity_level)
      if entity_level == ENTITY_TYPE_STATE
        # Get Score from Data which is in Active Record
        data.state_value_text|| data.state_value_float
      else
        band == PROFICIENT_AND_ABOVE_BAND ?  data['score']: data[band+'_score']
      end
    end

    def transpose_band_name(band)
      # For proficient and above band id is always null in database
      band == nil ? PROFICIENT_AND_ABOVE_BAND:  band
    end

    def transpose_band_id(band, data, entity_level)
      # For proficient and above band id is always null in database
      if entity_level == ENTITY_TYPE_STATE
        data['proficiency_band_id']
      else
        data[band+'_band_id']
      end
    end

    def transpose_number_tested(data,band,entity_level)
      if entity_level == ENTITY_TYPE_STATE
        data['number_students_tested']
      else
        band == PROFICIENT_AND_ABOVE_BAND ?  data['number_students_tested']:         data[band+'_number_students_tested']
      end
    end

    def get_band_names(data)
      bands = data.keys.select { |key| key.ends_with?('band_id') }
      proficient_score  = data.has_key? 'score'
      band_names = bands.map { |band| band[0..(band.length-'_band_id'.length-1)] }
      if proficient_score
        band_names << PROFICIENT_AND_ABOVE_BAND
      end
      band_names
    end
  end

  class TestDataSetDecorator
    include Feeds::FeedConstants

    @@proficiency_bands = Hash[TestProficiencyBand.all.map { |pb| [pb.id, pb] }]
    @@test_data_subjects = Hash[TestDataSubject.all.map { |o| [o.id, o] }]
    @@test_data_breakdowns = Hash[TestDataBreakdown.all.map { |bd| [bd.id, bd] }]
    @@test_data_breakdowns_name_mapping = Hash[TestDataBreakdown.all.map { |bd| [bd.name, bd] }]

    attr_reader :test_data_set, :state

    def initialize(state, test_data_set)
      @state = state
      @test_data_set = test_data_set
    end

    def proficiency_band_name
      if @@proficiency_bands[test_data_set['proficiency_band_id']].present?
        @@proficiency_bands[test_data_set['proficiency_band_id']].name || PROFICIENT_AND_ABOVE_BAND
      else
        PROFICIENT_AND_ABOVE_BAND
      end
    end

    def subject_name
      @@test_data_subjects[test_data_set.subject_id].present? ? @@test_data_subjects[test_data_set.subject_id].name : ''
    end

    def breakdown_name
      @@test_data_breakdowns[test_data_set.breakdown_id].present? ? @@test_data_breakdowns[test_data_set.breakdown_id].name : ''
    end

    def proficiency_band_id(entity_level)
      # For proficient and above band id is always null in database
      if entity_level == ENTITY_TYPE_STATE
        test_data_set['proficiency_band_id']
      else
        test_data_set[proficiency_band_name + '_band_id']
      end
    end

    def number_tested(entity_level)
      if entity_level == ENTITY_TYPE_STATE
        test_data_set['number_students_tested']
      else
        proficiency_band_name == PROFICIENT_AND_ABOVE_BAND ? test_data_set['number_students_tested'] : test_data_set[proficiency_band_name + '_number_students_tested']
      end
    end

    def breakdown_id
      name = breakdown_name == 'All' ? 'All students' : breakdown_name
      test_data_set['breakdown_id'].present? ? test_data_set['breakdown_id'] : @@test_data_breakdowns_name_mapping[name].try(:id)
    end

    def method_missing(method, *args)
      test_data_set.send(method, *args)
    end

    def test_id
      state.upcase + test_data_set['data_type_id'].to_s.rjust(5, '0')
    end

    def test_score(entity_level)
      if entity_level == ENTITY_TYPE_STATE
        # Get Score from Data which is in Active Record
        test_data_set.state_value_text || test_data_set.state_value_float
      else
        proficiency_band_name == PROFICIENT_AND_ABOVE_BAND ? data['score']: data[band+'_score']
      end
    end

    def universal_id(entity = nil, entity_level)
      if entity_level == ENTITY_TYPE_DISTRICT
        '1' + state_fips[state.upcase] + entity.id.to_s.rjust(5, '0')
      elsif entity_level == ENTITY_TYPE_SCHOOL
        state_fips[state.upcase] + entity.id.to_s.rjust(5, '0')
      else
        state_fips[state.upcase]
      end
    end
  end




  class StateDataStuff
    include Feeds::FeedConstants

    attr_reader :state, :data_type

    def initialize(state, data_type)
      @state = state
      @data_type = data_type
    end

    def xml_data
      transpose_state_data_for_feed(test_score_data)
    end

    def transpose_state_data_for_feed(state_test_data)
      state_level_test_data = []
      state_test_data.each do |data|
        data = TestDataSetDecorator.new(state, data)
        band = data.proficiency_band_name
        entity_level = ENTITY_TYPE_STATE
        grade = data['grade_name']
        year = data['year']
        level = data['level_code']
        subject = data.subject_name
        breakdown_name = data.breakdown_name
        breakdown_id = data['breakdown_id']
        entity = nil

        ###
        test_data_hash = {
          :universal_id => data.universal_id(entity, entity_level),
          :test_id => data.test_id,
          :year => year,
          :subject_name => subject,
          :grade_name => grade,
          :level_code_name => level,
          :score => data.test_score(entity_level),
          :proficiency_band_id => data.proficiency_band_id(entity_level),
          :proficiency_band_name => band
        }
        additional_data_for_subgroup = {
          :breakdown_id => data.breakdown_id,
          :breakdown_name => breakdown_name
        }
        number_tested = { :number_tested => data.number_tested(entity_level) }
        data_type == WITH_ALL_BREAKDOWN ? test_data_hash.merge!(additional_data_for_subgroup).merge!(number_tested) : test_data_hash.merge!(number_tested)
        ###


        # test_data = create_hash_for_xml(state,band, data, nil, entity_level, grade, level, subject, test_id, year, data_type, breakdown_id,breakdown_name )
        test_data = test_data_hash


        state_level_test_data.push(test_data)
      end
      state_level_test_data
    end

    private

    def test_score_data
      @_test_score_data ||= (
        if data_type == WITH_NO_BREAKDOWN
          get_state_data_with_no_subgroup
        elsif data_type == WITH_ALL_BREAKDOWN
          get_state_data_with_subgroup
        end
      )
    end

    def get_state_data_with_no_subgroup
      TestDataSet.test_scores_for_state(state)
    end

    def get_state_data_with_subgroup
      TestDataSet.test_scores_subgroup_for_state(state)
    end

  end
end
