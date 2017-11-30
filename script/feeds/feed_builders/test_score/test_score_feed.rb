require_relative '../../feed_config/feed_constants'

require_relative 'data_builder'
require_relative 'district_data_builder'
require_relative 'school_data_builder'
require_relative 'state_feed'
require_relative 'state_info_feed'
require_relative 'entity_feed'
require_relative 'feed_entity_reader'
require_relative 'test_calculations'
require_relative 'feed_test_scores_cache_hash'
require_relative 'entity_test_data_reader'
require_relative 'state_test_data_reader'
require_relative 'test_data_set_decorator'
require_relative 'test_data_set_hash_decorator'


module Feeds
  # Uses other objects to get data for state, district and school feeds and writes it to an XML file
  class TestScoreFeed
    include Feeds::FeedConstants

    attr_accessor :state, :data_type, :school_ids, :district_ids, :state_feed, :school_feed, :district_feed, :state_info_feed

    def initialize(attributes = {})
      @state = attributes[:state]
      @district_ids = attributes[:district_ids]
      @school_ids = attributes[:school_ids]
      @feed_file_path = attributes[:feed_file]
      @root_element = attributes[:root_element]
      @schema = attributes[:schema]
      @data_type = attributes[:data_type]
      @batch_size = attributes[:batch_size]
      self.school_feed = EntityFeed.for_schools(state, @school_ids, @data_type, @batch_size)
      self.district_feed = EntityFeed.for_districts(state, @district_ids, @data_type, @batch_size)
      self.state_feed = EntityFeed.for_states(state, @data_type)
      self.state_info_feed = Feeds::StateInfoFeed.new(state, data_type)
    end

    def generate_feed
      # xsd_schema ='greatschools-test.xsd'
      within_root_node do
        # Generate State Test Master Data
        # Generates test info tag
        write_xml_tag(state_info_feed.to_hashes, 'test')

        # Generate state test data tag
        state_feed.each_result { |data| write_xml_tag(data, 'test-result') }
        # Generate School Info
        school_feed.each_result { |data| write_xml_tag(data, 'test-result') }
        # Generate District Info
        district_feed.each_result { |data| write_xml_tag(data, 'test-result') }
      end

      close_file
      # system("xmllint --noout --schema #{xsd_schema} #{xmlFile}")
    end

    def file
      @_file ||= File.open(@feed_file_path, 'w')
    end

    def xml_builder
      @_xml_builder ||= (
        xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
        xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
        xml
      )
    end

    def within_root_node
      xml_builder.tag!(
        @root_element,
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        :'xsi:noNamespaceSchemaLocation' => @schema,
      ) do
        yield(xml_builder)
      end
    end

    def close_file
      file.close
    end

    def write_xml_tag(data, tag_name)
      if data.present?
        data.reject(&:blank?).each do |tag_data|
          xml_builder.tag! tag_name do
            tag_data.compact.each do |key, value|
              xml_builder.tag! key.to_s.gsub('_', '-'), value
            end
          end
        end
      end
    end

  end

end
