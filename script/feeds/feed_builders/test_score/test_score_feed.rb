require_relative '../../feed_config/feed_constants'

require_relative 'data_builder'
require_relative 'district_data_builder'
require_relative 'school_data_builder'
require_relative 'state_data_builder'
require_relative 'state_info_builder'
require_relative 'entity_feed'
require_relative 'feed_entity_reader'
require_relative 'test_data_set_decorator'
require_relative 'feed_test_scores_cache_decorator'


module Feeds
  class TestScoreFeed
    include Feeds::FeedConstants

    attr_reader :state, :data_type, :school_ids, :district_ids

    def initialize(attributes = {})
      @state = attributes[:state]
      @district_ids = attributes[:district_ids]
      @school_ids = attributes[:school_ids]
      @feed_file = attributes[:feed_file]
      @root_element = attributes[:root_element]
      @schema = attributes[:schema]
      @data_type = attributes[:data_type]
      @batch_size = attributes[:batch_size]
      @school_feed = EntityFeed.for_schools(state, @school_ids, @data_type, @batch_size)
      @district_feed = EntityFeed.for_districts(state, @district_ids, @data_type, @batch_size)
    end

    def generate_feed
      # xsd_schema ='greatschools-test.xsd'
      #Generate State Test Master Data
      @state_test_infos_for_feed = state_info_builder.array_of_hashes

      @state_data_for_feed = state_data_builder.to_hash

      # Write to XML File
      generate_xml_test_score_feed
      # system("xmllint --noout --schema #{xsd_schema} #{xmlFile}")
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
                            @school_feed.each_result do |data|
                              write_xml_tag(data, 'test-result', xml)
                            end
                            #Generate District Info
                            @district_feed.each_result do |data|
                              write_xml_tag(data, 'test-result', xml)
                            end
                          end
                  }
    end

    def state_info_builder
      @_state_info_builder ||= Feeds::StateInfoBuilder.new(state, data_type)
    end

    def state_data_builder
      @_state_data_builder ||= Feeds::StateDataBuilder.new(state, data_type)
    end

    def write_xml_tag(data, tag_name, xml)
      if data.present?
        data_for_xml = data.reject(&:blank?)
        data_for_xml.reject(&:blank?).each do |tag_data|
          xml.tag! tag_name do
            tag_data.compact.each do |key, value|
              xml.tag! key.to_s.gsub('_', '-'), value
            end
          end
        end
      end
    end

  end
end
