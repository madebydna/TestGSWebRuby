module CommunityProfiles
  class DistrictLargest
    include Rails.application.routes.url_helpers
    include UrlHelper

    def initialize(cache_data_reader:)
      @cache_data_reader = cache_data_reader
    end

    def to_hash
      @_largest_districts_in_state ||= begin
        @cache_data_reader.largest_districts.map do |district|
          {}.tap do |h|
            h[:name] = district['name']
            h[:enrollment] = district['enrollment']
            h[:city] = district['city']
            h[:state] = district['state']
            h[:grades] = district['levels']
            h[:numSchools] = district['school_count']
            h[:url] = district_url(district_params(district['state'], district['city'], district['name']))
          end
        end
      end
    end
    
  end
end
