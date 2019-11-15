# frozen_string_literal: true

module Solr
  class DistrictDocument < Document
    def self.all_fields
      [].tap do |array|
        array << new_field(:district_id, type: FieldTypes::INTEGER) { district.id }
        array << new_field(:district_name, type: FieldTypes::TEXT) { district.name }
        array << new_field(:state, type: FieldTypes::STRING) { district.state.downcase }
        array << new_field(:city, type: FieldTypes::TEXT_LOCATION_SYNONYMS) { district.city }
        array << new_field(:number_of_schools, type: FieldTypes::INTEGER) { district.num_schools }
      end
    end

    define_field_methods(all_fields)

    def initialize(state: nil, district_id: nil, district: nil)
      @state = state
      @district_id = district_id
      @district = district
    end

    # indexable
    def self.document_type
      'District'
    end

    private

    # indexable
    def unique_key
      "#{state.downcase}-#{district_id}"
    end

    def district
      @district ||= begin
        raise "Illegal state: district or state and district_id are required" unless @state && @district_id
        DistrictRecord.by_state(@state.downcase).find_by(district_id: @district_id)
      end
    end
  end
end
