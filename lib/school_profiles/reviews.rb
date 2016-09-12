module SchoolProfiles
  class Reviews
    attr_reader :school

    def initialize(school)
       @school = school
    end

    def having_comments
      school.reviews.having_comments
    end
  end
end
