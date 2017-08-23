module Feeds
  # Uses other objects to get data for state, district and school feeds and writes it to an XML file
  class DirectoryXmlBuilder
    include Feeds::FeedConstants

    attr_accessor :state_feed, :school_feed, :district_feed, :state_info_feed

    def generate_feed(root_element, schema, feed_file_path, school_feed, district_feed, state_feed)
      @root_element = root_element
      @schema = schema
      @feed_file_path = feed_file_path
      within_root_node do
q        # Generate state-feed data tag
        state_feed.state_result { |data| write_xml_tag(data, 'state-feed') }
        # Generate District Info
        district_feed.each_result { |data| write_xml_tag(data, 'district') }
        # Generate School Info
        school_feed.each_result { |data| write_xml_tag(data, 'school') }
      end

      close_file
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
          :'xsi:noNamespaceSchemaLocation' => @schema
      ) do
        yield(xml_builder)
      end
    end

    def close_file
      file.close
    end

    def write_xml_tag(data, tag_name)
      if data.present?
        xml_builder.tag! tag_name do
          data.each do | d_obj |
            if d_obj && d_obj.value.present? && d_obj.key.present?
              if d_obj.value.is_a?(Array)
                write_xml_tag(d_obj.value, d_obj.key )
              else
                xml_builder.tag! d_obj.key.to_s, d_obj.value, d_obj.attributes
              end
            end
          end
        end
      end
    end

  end

end
