# frozen_string_literal: true

module Search
  class SchoolDocument
    include Indexable
    include Retrievable

    attr_reader :state, :school_id

    CACHE_KEYS = %w(ratings)

    def initialize(state:, school_id:)
      @state = state
      @school_id = school_id
    end

    # retrievable

    def self.from_unique_key(key)
      state, school_id = key.split("-")
      new(state: state, school_id: school_id)
    end

    # indexable

    def self.type
      "School"
    end

    def unique_key
      self.class.unique_key(@state, @school_id)
    end

    def build
      return unless school
      super

      test_score_ratings_by_breakdown = school.test_score_ratings_by_breakdown

      add_field(:name, school.name, type: Search::SolrIndexer::Types::TEXT)
      add_field(:sortable_name, school.name&.downcase)
      add_field(:city, school.city)
      add_field(:school_district_id, school.district_id)
      add_field(:school_district_name, school.district&.name)
      add_field(:street, school.street&.downcase)
      add_field(:zipcode, school.zipcode)
      add_field(:county, school.county&.downcase)
      add_field(:state, school.state.downcase)
      add_field(:latlon, latlon, type: Search::SolrIndexer::Types::LAT_LON)
      add_field(:level_codes, school.level_code&.split(","))
      add_field(:summary_rating, school.great_schools_rating)
      [
        :test_scores_rating,
        :academic_progress_rating,
        :college_readiness_rating,
        :equity_overview_rating,
      ].each do |rating_name|
        add_field(rating_name, school.send(rating_name))
      end
      add_field(:advanced_courses_rating, school.courses_rating)

      Breakdown.unique_ethnicity_names.each do |breakdown|
        field_name = "test_scores_rating_#{breakdown.downcase.gsub(" ", "_")}"
        add_field(field_name, test_score_ratings_by_breakdown.dig(breakdown))
      end
      add_field(
        "#{Breakdown.economically_disadvantaged_name.gsub(" ", "_")}_i",
        test_score_ratings_by_breakdown[Breakdown.economically_disadvantaged_name]
      )
    end

    # impl

    def self.unique_key(state, school_id)
      "#{state.downcase}-#{school_id}"
    end

    private

    def school
      @_school ||= begin
        school = School.find_by_state_and_id(@state, @school_id)
        query = SchoolCacheQuery.new.include_cache_keys(CACHE_KEYS).include_schools(@state, @school_id)
        query_results = query.query_and_use_cache_keys
        school_cache_results = SchoolCacheResults.new(CACHE_KEYS, query_results)
        school = school_cache_results.decorate_schools([school]).first
        school
      end
    end

    def latlon
      "#{school.lat},#{school.lon}" if school.lat && school.lon
    end

  end
end
