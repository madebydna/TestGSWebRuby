require_relative '../feed_config/feed_constants'
# require_relative 'feed_data_helper'

module Feeds
  module FeedHelper

    # Included to get the rails action Url to generate district , profile and state url
    include Rails.application.routes.url_helpers
    include UrlHelper


    include Feeds::FeedConstants

    # This method is needed to Use URLHelper to generate State , School and District Url
    def default_url_options
      hash = {}
      # the feed Url need to have production host values irrespective of the server the feeds are being running on hence the value is set here
      hash[:host] = 'www.greatschools.org'
      hash[:port]= nil
      hash
    end


    def get_feed_name(feed, index,location,names,state)
      feed_location = location || ''
      feed_name = names.present? && names[index].present? ? names[index] : FEED_NAME_MAPPING[feed]
      #generated_feed_file_name = feed_name.present? ? feed_name+"-#{@state.upcase}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml" : feed+"-#{@state.upcase}_#{Time.now.strftime("%Y-%m-%d_%H.%M.%S.%L")}.xml"
      generated_feed_file_name = if feed_name.present?
                                   if feed_name =~ /proficiency/
                                     feed_name+".xml"
                                   else
                                     feed_name+"-#{state.upcase}.xml"
                                   end
                                 else
                                   feed+"-#{state.upcase}.xml"
                                 end
      # removing timestamp for now as flat feed process does not like timestamp
      feed_location+generated_feed_file_name
    end

    def transpose_test_id(state,test_id)
      state.upcase+ test_id.to_s.rjust(5, '0')
     end

    def transpose_universal_id(state,entity = nil, entity_level)
      if entity_level == ENTITY_TYPE_DISTRICT
        entity_id = entity.is_a?(DistrictRecord) ? entity.district_id : entity.id
        '1' + state_fips[state.upcase] + entity_id.to_s.rjust(5, '0')
      elsif entity_level == ENTITY_TYPE_SCHOOL
        state_fips[state.upcase] + entity.id.to_s.rjust(5, '0')
      else
        state_fips[state.upcase]
      end

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
