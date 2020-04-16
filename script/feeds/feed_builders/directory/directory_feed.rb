require_relative '../../feed_config/feed_constants'
require_relative '../../feed_helpers/universal_id'

require_relative 'entity_directory_feed'
require_relative '../single_data_object'
require_relative 'directory_xml_builder'
require_relative 'characteristics_data_builder'
require_relative 'directory_data_builder'
require_relative 'directory_state_data_builder'

require 'states'


module Feeds
  class DirectoryFeed
    include Feeds::FeedConstants

    attr_accessor :state, :data_type, :school_ids, :district_ids, :state_feed, :school_feed, :district_feed, :state_info_feed

    def initialize(attributes = {})
      @state = attributes[:state]
      @district_ids = attributes[:district_ids].present? ? attributes[:district_ids] :  DistrictRecord.ids_by_state(@state)
      @school_ids = attributes[:school_ids].present? ? attributes[:school_ids] : School.ids_by_state(@state)
      @feed_file_path = attributes[:feed_file]
      @root_element = attributes[:root_element]
      @schema = attributes[:schema]
      @data_type = attributes[:data_type]

      self.school_feed = EntityDirectoryFeed.for_schools(state, @school_ids, @data_type)
      self.district_feed = EntityDirectoryFeed.for_districts(state, @district_ids, @data_type)
      self.state_feed = EntityDirectoryFeed.for_states(state, @data_type)
    end

    def generate_feed(format='')
      case format
        when 'xml'
          DirectoryXmlBuilder.new.generate_feed(@root_element, @schema, @feed_file_path, school_feed, district_feed, state_feed)
        when 'json'
        when 'flat'
        else
          DirectoryXmlBuilder.new.generate_feed(@root_element, @schema, @feed_file_path, school_feed, district_feed, state_feed)
      end
    end

  end

end
