$LOAD_PATH.unshift File.dirname(__FILE__)
require_relative '../feed_helpers/feed_logger'
require_relative '../feed_config/feed_constants'

require 'nokogiri'

module Feeds
  class ValidateFeedFiles
    include Feeds::FeedConstants

    def self.validate
      ValidateFeedFiles.new.validate
    end

    def validate
      xml_location = get_xml_location
      usage unless xml_location.present?
      list_of_xml = get_list_of_xml_to_validate(xml_location)
      if list_of_xml.empty?
        Feeds::FeedLog.log.error "Could not locate any xml at  #{xml_location} to validate"
      end
      download_xsd
      feed_name_xsd_map.each do |feed_type|
        validate_feed_type(feed_type, list_of_xml)
      end
    end

    private

    def get_xml_location
      if ARGV[0].present? && ARGV[1].nil?
        ARGV[0]
      end
    end

    def usage
      abort "\n\nUSAGE: rails runner script/feeds/feed_scripts/validate_feed_files.rb <location of folder>
      Ex: rails runner script/feeds/feed_scripts/validate_feed_files.rb /var/tmp/fullstate/
      \n\n"
    end

    def validate_feed_type(feed_type, list_of_xml)
      xsd = Nokogiri::XML::Schema(File.read(feed_type[:xsd]))
      list_of_xml.each do |xml|
        if xml.match(feed_type[:file_name])
          validate_xml(xml, xsd)
        end
      end
    end

    def get_list_of_xml_to_validate(xml_location)
      Array.wrap(Dir.glob(xml_location + "*.xml"))
    end

    def download_xsd
      FEED_TO_SCHEMA_MAPPING.try(:each) do |k, file|
        uri = URI.parse(file)
        xsd_file_name =URI(uri).path.split('/').last
        resp = Net::HTTP.get_response(uri)
        open(xsd_file_name, "wb") { |file|
          file.write(resp.body)
        }
      end
    end

    def validate_xml(xml, xsd)
      xsd.validate(xml).each do |error|
        Feeds::FeedLog.log.error "#{xml} #{error.line} :: #{error.message}"
      end
    end

    def feed_name_xsd_map
        FEED_NAME_MAPPING.try(:map) do |key, value|
        {
            :name => key,
            :file_name => value,
            :xsd => URI(FEED_TO_SCHEMA_MAPPING[key]).path.split('/').last
        }
      end
    end
  end
  ValidateFeedFiles.validate
end