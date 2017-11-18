module Feeds
  module City
    class XmlWriter
      include Feeds::FeedConstants

      def initialize(root_element, schema, feed_file_path)
        @root_element = root_element
        @schema = schema
        @feed_file_path = feed_file_path
      end

      def write_feed(feed, fields = [])
        within_root_node do
          feed.each_result do |data|
            if fields.present?
              data.slice!(*fields)
            end
            write_xml_tag(data, 'city')
          end
        end
        close_file
      end


      private


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
            data.each do |key, value|
              if value.is_a?(Array)
                value.each { |hash| write_xml_tag(hash, key) }
              else
                xml_builder.tag! key, value
              end
            end
          end
        end
      end
    end
  end
end
