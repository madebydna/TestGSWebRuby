# frozen_string_literal: true

require_relative './state_data_reader'
require_relative './district_data_reader'
require_relative './school_data_reader'

module Feeds
  module Directory
    class DataReader
      include Feeds::FeedConstants
      include Feeds::FeedHelper

      attr_reader :schools, :districts, :state

      def initialize(state, schools, districts)
        @state = state
        @schools = schools
        @districts = districts
      end

      def school_data_reader(school)
        Feeds::Directory::SchoolDataReader.new(state, school)
      end

      def district_data_reader(district)
        Feeds::Directory::DistrictDataReader.new(state, district)
      end

      def state_data_reader
        Feeds::Directory::StateDataReader.new(state)
      end
    end
  end
end