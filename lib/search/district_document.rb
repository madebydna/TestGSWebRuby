# frozen_string_literal: true

module Search
  class DistrictDocument
    include Indexable
    include Retrievable

    attr_reader :state, :district_id

    def initialize(state:, district_id:)
      @state = state
      @district_id = district_id
    end

    # retrievable

    def self.from_unique_key(key)
      state, district_id = key.split('-')
      new(state: state, district_id: district_id)
    end

    # indexable

    def self.type
      'District'
    end

    def unique_key
      self.class.unique_key(@state, @district_id)
    end

    def build
      return {} unless district
      super
      add_field(:district_name, district.name, Search::SolrIndexer::Types::TEXT)
      add_field(:state, district.state.downcase, Search::SolrIndexer::Types::STRING)
      add_field(:city, district.city, Search::SolrIndexer::Types::STRING)
      add_field(:number_of_schools, district.num_schools, Search::SolrIndexer::Types::INTEGER)
    end

    # impl

    def self.unique_key(state, district_id)
      "#{state.downcase}-#{district_id}"
    end

    private

    def district
      @_district ||= begin
        District.on_db(@state.downcase.to_sym).find_by_id(@district_id)
      end
    end
  end
end
