module SchoolProfiles
  class Hero
    include DefHasPredicates
    attr_reader :school, :school_cache_data_reader

    delegate :gs_rating, to: :school_cache_data_reader
    delegate :address, :type, to: :school, prefix: :school
    delegate :district, to: :school

    # Makes has_district?,  has_address?, etc
    def_has_predicates :district, :address, :gs_rating

    def initialize(school, school_cache_data_reader:)
      self.school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def school=(school)
      raise ArgumentError('School must be provided') if school.nil?
      SchoolProfiles::SchoolPresentationMethods.extend(school)
      @school = school
    end

    def district_name
      return unless has_district?
      school.district.name
    end
  end
end
