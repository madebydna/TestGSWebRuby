require 'forwardable'
module SchoolProfiles
  class Hero
    extend Forwardable

    attr_reader :school_cache_data_reader

    def_delegators :school_cache_data_reader, :gs_rating

    def initialize(school_cache_data_reader:)
      @school_cache_data_reader = school_cache_data_reader
    end
  end
end
