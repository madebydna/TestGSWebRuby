# frozen_string_literal: true

module Solr
  class SchoolDocument < Document
    CACHE_KEYS = %w(ratings)

    module CollectionMethods
      def load_external_data!
        schools = School.load_all_from_associates(self, &:include_district_name)
        # schools_with_caches = SchoolCacheQuery.decorate_schools(schools, CACHE_KEYS)
        each_with_index do |school_document, index|
          # school_document.school = schools_with_caches[index]
          school_document.school = schools[index]
        end
        return self
      end
    end

    def self.directory_fields
      @_directory_fields ||= (
        [].tap do |array|
          array << new_field(:school_id, type: FieldTypes::INTEGER) { school.id }
          array << new_field(:name, type: FieldTypes::TEXT) { school.name }
          array << new_field(:sortable_name, type: FieldTypes::STRING) { school.name&.downcase }
          array << new_field(:city, type: FieldTypes::TEXT_LOCATION_SYNONYMS) { school.city }
          array << new_field(:city_untokenized, type: FieldTypes::STRING) { school.city&.downcase }
          array << new_field(:school_district_id, type: FieldTypes::STRING) { school.district_id }
          array << new_field(:school_district_name, type: FieldTypes::STRING) { school.district&.name }
          array << new_field(:school_district_city, type: FieldTypes::STRING) { school.district&.city }
          array << new_field(:street, type: FieldTypes::STRING) { school.street&.downcase }
          array << new_field(:zipcode, type: FieldTypes::STRING) { school.zipcode }
          array << new_field(:county, type: FieldTypes::STRING) { school.county&.downcase }
          array << new_field(:state, type: FieldTypes::STRING) { school.state.downcase }
          array << new_field(:latlon, type: FieldTypes::LAT_LON) { "#{school.lat},#{school.lon}" if school.lat && school.lon }
          array << new_field(:level_codes, type: FieldTypes::STRING, multi_valued: true) { school.level_code&.split(",") }
          array << new_field(:entity_type, type: FieldTypes::STRING) { school.type.downcase }
        end
      )
    end

    def self.rating_fields
      @_rating_fields ||= (
        [].tap do |array|
          array << new_field(:summary_rating, type: FieldTypes::INTEGER) { school.great_schools_rating }
          array << new_field(:csa_badge, type: FieldTypes::INTEGER, multi_valued: true) { school.csa_award_winner_years }
          [
            :test_scores_rating,
            :academic_progress_rating,
            :college_readiness_rating,
            :equity_overview_rating,
            :student_progress_rating,
          ].each do |rating_name|
            array << new_field(rating_name, type: FieldTypes::INTEGER) { school.send(rating_name) }
          end
          array << new_field(:advanced_courses_rating, type: FieldTypes::INTEGER) { school.courses_rating }
        end
      )
    end

    def self.rating_subgroup_fields
      @_rating_subgroup_fields ||= (
        [].tap do |array|
          Omni::Breakdown.unique_ethnicity_names.each do |breakdown|
            field_name = "test_scores_rating_#{breakdown.downcase.gsub(" ", "_")}".to_sym
            array << new_field(field_name, type: FieldTypes::INTEGER) { school.test_score_ratings_by_breakdown.dig(breakdown) }
          end
          array << new_field(
            "#{Omni::Breakdown.economically_disadvantaged_name.gsub(" ", "_")}".to_sym,
            type: FieldTypes::INTEGER
          ) do
            school.test_score_ratings_by_breakdown[Omni::Breakdown.economically_disadvantaged_name]
          end
        end
      )
    end

    def self.rating_subgroup_field_name(rating_type, breakdown)
      breakdown&.downcase == 'low-income' ? 'Economically_disadvantaged' : [rating_type, breakdown].compact.join('_').downcase.gsub(" ", "_")
    end

    def self.all_fields
      self.directory_fields +
      self.rating_fields +
      self.rating_subgroup_fields
    end

    def self.breakdown_to_rating_field_name
      @_breakdown_to_rating_field_name ||= (
        equity_hash = { "Low-income" => "Economically_disadvantaged" }
        Omni::Breakdown.unique_ethnicity_names.each do |breakdown|
          equity_hash[breakdown] = "test_scores_rating_#{breakdown.downcase.gsub(" ", "_")}"
        end
        equity_hash
      )
    end

    def self.rating_field_name_to_breakdown
      @_rating_field_name_to_breakdown ||= breakdown_to_rating_field_name.invert
    end

    define_field_methods(all_fields)

    attr_writer :id, :type, :school, :created

    def initialize(state: nil, school_id: nil, school: nil)
      @state = state&.downcase
      @school_id = school_id
      @school = school
    end

    # indexable
    def self.document_type
      "School"
    end

    def unique_key
      "#{state.downcase}-#{school_id}"
    end

    def id
      school_id
    end

    def method_missing(name, *args, &block)
      if school.respond_to?(name, true)
        school.send(name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(name, *args)
      school.respond_to?(name, *args) || super
    end

    private

    def school
      @school ||= begin
        raise "Illegal state: school or state and school_id are required" unless @state && @school_id
        s = School.find_by_state_and_id(@state, @school_id)
        raise "Could not find school #{@state}-#{@school_id}" unless s
        query = SchoolCacheQuery.new.include_cache_keys(CACHE_KEYS).include_schools(@state, @school_id)
        query_results = query.query_and_use_cache_keys
        school_cache_results = SchoolCacheResults.new(CACHE_KEYS, query_results)
        s = school_cache_results.decorate_schools([s]).first
        s
      end
    end

  end
end
