module SchoolProfiles
  class PageViewMetadata

    attr_reader :school, :page_name, :school_reviews_count, :gs_rating

    SCHOOL_PROFILE_TEMPLATE = "SchoolProf"

    def initialize(school, page_name, gs_rating, school_reviews_count)
      @school = school
      @gs_rating = gs_rating
      @page_name = page_name
      @school_reviews_count = school_reviews_count
    end

    def hash
      {
        'page_name'   => page_name,
        'City'        => school.city,
        'county'      => school.county, # county name?
        'gs_rating'   => gs_rating.to_s,
        'level'       => school.level_code, # p,e,m,h
        'school_id'   => school.id.to_s,
        'State'       => school.state, # abbreviation
        'type'        => school.type,  # private, public, charter
        'zipcode'     => school.zipcode,
        'district_id' => school.district.present? ? school.district.id.to_s : "",
        'template'    => SCHOOL_PROFILE_TEMPLATE,
        'collection_ids'  => school.collection_ids,
        'number_of_reviews_with_comments' =>  school_reviews_count,
      }
    end
  end
end
