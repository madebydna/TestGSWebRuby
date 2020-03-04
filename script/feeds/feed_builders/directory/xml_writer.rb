module Feeds
  module Directory
    class XmlWriter
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      attr_reader :data_reader

      def initialize(data_reader, output_path)
        @root_element = 'gs-local-feed'
        @schema = 'https://www.greatschools.org/feeds/local-greatschools.xsd'
        @feed_file_path = output_path
        @data_reader = data_reader
      end

      def file
        @_file ||= File.open(@feed_file_path, 'w')
      end

      def write_feed
        within_root_node do
          write_state_feed
          write_districts_feed
          write_schools_feed
        end
        close_file
      end

      def write_state_feed
        state_feed = @data_reader.state_data_reader
        state_attributes = state_feed.data_values

        within_tag('state-feed') do
          write_state_attributes_feed(state_attributes)
          write_census_feed(state_feed)
        end
      end

      def write_state_attributes_feed(data_hash)
        DIRECTORY_STATE_ATTRIBUTES.each do |attribute|
          feed_attribute = attribute.gsub('_','-')
          xml_builder.tag!(feed_attribute, data_hash[feed_attribute])
        end
      end

      def write_districts_feed
        districts = data_reader.districts
        districts.each do |district|
          write_district_feed(district)
        end
      end

      def write_district_feed(district)
        district_feed = data_reader.district_data_reader(district)
        district_attributes = district_feed.data_values

        within_tag('district') do
          write_district_attributes_feed(district_attributes)
          write_census_feed(district_feed)
        end
      end

      def write_district_attributes_feed(data_hash)
        DIRECTORY_DISTRICT_ATTRIBUTES.each do |attribute|
          feed_attribute = attribute.gsub('_','-').downcase
          data = data_hash[feed_attribute]
          next unless data.present? || required_field?('district', attribute)

          if !data.present? && required_field?('district', attribute)
            xml_builder.tag!(feed_attribute, nil)
          elsif feed_attribute == 'url'
            xml_builder.tag!(feed_attribute, data, {type: "District Overview", "universal-id": data_hash["universal-id"]})
          else
            xml_builder.tag!(feed_attribute, data)
          end
        end
      end

      def write_schools_feed
        schools = data_reader.schools
        schools.each do |school|
          write_school_feed(school)
        end
      end

      def write_school_feed(school)
        school_feed = data_reader.school_data_reader(school)
        school_attributes = school_feed.data_values
        within_tag('school') do
          write_school_attributes_feed(school_attributes)
          write_census_feed(school_feed)
          xml_builder.tag!('school-summary', school_feed.data_value('school_summary'))
        end
      end

      def write_school_attributes_feed(data_hash)
        DIRECTORY_SCHOOL_ATTRIBUTES.each do |attribute|
          feed_attribute = attribute.gsub('_','-').downcase
          data = data_hash[feed_attribute]
          next unless data_hash[feed_attribute].present? || required_field?('school', attribute)

          if !data.present? && required_field?('school', attribute)
            xml_builder.tag!(feed_attribute, nil)
          elsif feed_attribute == 'url'
            xml_builder.tag!('url', data, {type: 'School Overview', 'universal-id' => data_hash["universal-id"]})
            xml_builder.tag!('url', data, {type: 'Ratings', 'universal-id' => data_hash["universal-id"]})
            xml_builder.tag!('url', data + '#Students', {type: 'Student/Teacher', 'universal-id' => data_hash["universal-id"]})
            xml_builder.tag!('url', data + '#Reviews', {type: 'Parent Reviews', 'universal-id' => data_hash["universal-id"]})
            xml_builder.tag!('url', data + '#Test_scores', {type: 'Test Scores', 'universal-id' => data_hash["universal-id"]})
          else
            xml_builder.tag!(feed_attribute, data)
          end
        end
      end

      def write_census_feed(entity_data_reader)
        census_data_hash = entity_data_reader.census_info
        return if census_data_hash.empty?

        within_tag('census-info') do
          CENSUS_CACHE_ACCESSORS.each do |accessor|
            data_values = census_data_hash.fetch(accessor[:key], nil)
            next unless data_values

            data_values.each do |data_hash|
              within_tag(accessor[:feed_name]) do
                accessor[:attributes].each do |key|
                  xml_builder.tag!(key.to_s.gsub("_","-"), data_hash[key])
                end
              end
            end
          end
        end
      end

      def xml_builder
        @_xml_builder ||= begin
          xml = Builder::XmlMarkup.new(:target => file, :indent => 1)
          xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
          xml
        end
      end

      def within_root_node
        xml_builder.tag!(
            @root_element,
            'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
            :'xsi:noNamespaceSchemaLocation' => @schema
        ) do
          yield(xml_builder)
        end
      end

      def required_field?(entity, attribute)
        if entity == 'school'
          DIRECTORY_SCHOOL_KEYS_REQUIRED.include?(attribute)
        elsif entity == 'district'
          DIRECTORY_DISTRICT_KEYS_REQUIRED.include?(attribute)
        else
          raise StandardError.new("Entity has not been whitelisted for xml")
        end
      end

      def close_file
        file.close
      end

      def within_tag(tag_name)
        xml_builder.tag! tag_name do
          yield(xml_builder)
        end
      end
    end
  end
end