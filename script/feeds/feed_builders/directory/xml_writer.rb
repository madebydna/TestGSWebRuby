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

        within_tag('state-feed') do
          xml_builder.tag!('universal-id', state_feed.universal_id)
          xml_builder.tag!('state-name', state_feed.state_name)
          xml_builder.tag!('state', state_feed.state)
          write_census_feed(state_feed)
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
        state_feed = data_reader.state_data_reader

        within_tag('district') do
          xml_builder.tag!('universal-id', district_feed.universal_id)
          xml_builder.tag!('state-id', state_feed.universal_id)
          xml_builder.tag!('nces-code', district.nces_code)
          xml_builder.tag!('name', district.name)
          xml_builder.tag!('description', district_feed.data_value('description'))
          xml_builder.tag!('street', district.street)
          xml_builder.tag!('city', district.city)
          xml_builder.tag!('state', district.state.upcase)
          xml_builder.tag!('zipcode', district.zipcode)
          xml_builder.tag!('county', district.county)
          xml_builder.tag!('FIPScounty', district_feed.data_value('FIPScounty'))
          xml_builder.tag!('level', district_feed.level)
          xml_builder.tag!('level-code', district_feed.data_value('level_code'))
          xml_builder.tag!('lat', district.lat)
          xml_builder.tag!('lon', district.lon)
          xml_builder.tag!('phone', district.phone)
          xml_builder.tag!('fax', district.fax)
          xml_builder.tag!('web-site', district_feed.data_value('home_page_url'))
          xml_builder.tag!('url', district_feed.data_value('home_page_url'), {type: 'District Overview', 'universal-id' => district_feed.universal_id})
          write_census_feed(district_feed)
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
        state_feed = data_reader.state_data_reader

        within_tag('school') do
          xml_builder.tag!('universal-id', school_feed.universal_id)
          xml_builder.tag!('id', school.id)
          xml_builder.tag!('state-id', state_feed.universal_id)
          xml_builder.tag!('nces-code', school.nces_code)
          xml_builder.tag!('name', school.name)
          xml_builder.tag!('description', school_feed.data_value('description'))
          xml_builder.tag!('street', school.street)
          xml_builder.tag!('zipcode', school.zipcode)
          xml_builder.tag!('county', school.county)
          xml_builder.tag!('FIPScounty', school_feed.data_value('FIPScounty'))
          xml_builder.tag!('level', school_feed.level)
          xml_builder.tag!('level-code', school_feed.data_value('level_code'))
          xml_builder.tag!('district-id', school.district_id)
          xml_builder.tag!('lat', school.lat)
          xml_builder.tag!('lon', school.lon)
          xml_builder.tag!('phone', school.phone)
          xml_builder.tag!('fax', school.fax)
          xml_builder.tag!('web-site', school_feed.data_value('home_page_url'))
          xml_builder.tag!('subtype', school.subtype)
          xml_builder.tag!('type', school.type)
          xml_builder.tag!('district-name', school_feed.data_value('district_name'))
          xml_builder.tag!('universal-district-id', school_feed.universal_district_id)
          # xml_builder.tag!('district-spending', )
          xml_builder.tag!('url', school_feed.data_value('url'), {type: 'School Overview', 'universal-id' => school_feed.universal_id})
          xml_builder.tag!('url', school_feed.data_value('url'), {type: 'Ratings', 'universal-id' => school_feed.universal_id})
          xml_builder.tag!('url', school_feed.data_value('url') + '#Students', {type: 'Student/Teacher', 'universal-id' => school_feed.universal_id})
          xml_builder.tag!('url', school_feed.data_value('url') + '#Reviews', {type: 'Parent Reviews', 'universal-id' => school_feed.universal_id})
          xml_builder.tag!('url', school_feed.data_value('url') + '#Test_scores', {type: 'Test Scores', 'universal-id' => school_feed.universal_id})
          write_census_feed(school_feed)
          xml_builder.tag!('school-summary', school_feed.data_value('school_summary'))
        end
      end

      def write_census_feed(entity_data_reader)
        within_tag('census-info') do
          entity_data_reader.census_info.each do |data_hash|
            data_hash.each do |key, value|
              if value.is_a? Array
                value.each do |data_point|
                  within_tag(key) do
                    data_point.keys.each do |attribute|
                      xml_builder.tag!(attribute.to_s.gsub("_","-"), data_point[attribute])
                    end
                  end
                end
              else
                within_tag(key) do
                  value.keys.each do |attribute|
                    xml_builder.tag!(attribute.to_s.gsub("_","-"), value[attribute])
                  end
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