module SchoolProfiles
  class DistanceLearning
    include UrlHelper

    attr_reader :school, :district_cache_data_reader

    def initialize(school, district_cache_data_reader:)
      @school = school
      @district_cache_data_reader = district_cache_data_reader
    end

    def distance_learning_district?
      district_cache_data_reader&.distance_learning.present?
    end

    def data_values
      @_data_values ||=begin
        return nil unless distance_learning_district?

        district_params = district_params_from_district(school.district)

        OpenStruct.new.tap do |dv|
          dv.district = district_params[:district]
          dv.state = district_params[:state]
          dv.city = district_params[:city]
          dv.description = "PLACEHOLDER - THIS SCHOOL IS PART OF A DISTRICT THAT HAS REMOTE LEARNING STUFF"
        end
      end
    end
  end
end