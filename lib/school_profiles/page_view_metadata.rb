module SchoolProfiles
  class PageViewMetadata

    attr_reader :school, :page_name, :school_reviews_count, :gs_rating, :csa_badge, :distance_learning

    SCHOOL_PROFILE_TEMPLATE = "SchoolProf"

    def initialize(school, page_name, gs_rating, school_reviews_count, csa_badge, distance_learning)
      @school = school
      @gs_rating = gs_rating
      @page_name = page_name
      @school_reviews_count = school_reviews_count
      @csa_badge = csa_badge
      @distance_learning = distance_learning
    end

    def hash
      {}.tap do |dlc|
        dlc['page_name'] = page_name
        dlc['City'] = school.city
        dlc['county'] = school.county # county name?
        dlc['gs_rating'] = gs_rating.to_s
        dlc['level'] = school.level_code # p,e,m,h
        dlc['school_id'] = school.id.to_s
        dlc['State'] = school.state # abbreviation
        dlc['type'] = school.type # private, public, charter
        dlc['zipcode'] = school.zipcode
        dlc['district_id'] = school.district.present? ? school.district.district_id.to_s : ""
        dlc['template'] = SCHOOL_PROFILE_TEMPLATE
        dlc['number_of_reviews_with_comments'] = school_reviews_count
        # untruncated values
        dlc['city_long'] = SchoolProfiles::PageViewMetadata.sanitize_for_dfp(school.city)
        dlc['address'] = SchoolProfiles::PageViewMetadata.sanitize_for_dfp(school.street)
        dlc[PageAnalytics::GS_BADGE] = 'CSAWinner' if csa_badge
        dlc[PageAnalytics::GS_TAGS] = 'DistanceLearningData' if distance_learning.present?
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
