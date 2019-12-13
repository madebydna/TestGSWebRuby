module SchoolProfiles
  class PageViewMetadata

    attr_reader :school, :page_name, :school_reviews_count, :gs_rating, :csa_badge

    SCHOOL_PROFILE_TEMPLATE = "SchoolProf"

    def initialize(school, page_name, gs_rating, school_reviews_count, csa_badge)
      @school = school
      @gs_rating = gs_rating
      @page_name = page_name
      @school_reviews_count = school_reviews_count
      @csa_badge = csa_badge
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
        'district_id' => school.district.present? ? school.district.district_id.to_s : "",
        'template'    => SCHOOL_PROFILE_TEMPLATE,
        'number_of_reviews_with_comments' =>  school_reviews_count,
        # untruncated values
        'city_long'   => SchoolProfiles::PageViewMetadata.sanitize_for_dfp(school.city),
        'address'    => SchoolProfiles::PageViewMetadata.sanitize_for_dfp(school.street)
      }.tap do |h|
        h[PageAnalytics::GS_BADGE] = 'CSAWinner' if csa_badge
      end
    end

    # For now just strip the characters out since CGI::encode_www_form_component -- in particular that method does not
    # encode * which is disallowed by DFP, and further it encodes spaces as + which is disallowed by DFP.
    # See https://support.google.com/admanager/answer/177381?hl=en for the full list of characters disallowed in
    # Ad Manager targetting key/values
    def self.sanitize_for_dfp(value='')
      value.gsub(/[',#&()]/, '')
    end
  end
end
