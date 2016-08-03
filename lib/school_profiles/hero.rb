module SchoolProfiles
  class Hero
    attr_reader :school, :school_cache_data_reader

    delegate :gs_rating, to: :school_cache_data_reader

    delegate :address, to: :school, prefix: :school

    def initialize(school, school_cache_data_reader:)
      self.school = school
      @school_cache_data_reader = school_cache_data_reader
    end

    def school=(school)
      raise ArgumentError('School must be provided') if school.nil?
      SchoolProfiles::SchoolPresentationMethods.extend(school)
      @school = school
    end
  end
end
