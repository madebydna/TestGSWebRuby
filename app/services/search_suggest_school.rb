class SearchSuggestSchool < SearchSuggester
  include UrlHelper

  def get_results(solr_options)
    Solr.new.school_name_suggest(solr_options)
  end

  def process_result(school_search_result)
    school_state_name = States.abbreviation_hash[school_search_result['state'].downcase]
    school_url = school_search_result['school_profile_path'] || "/#{gs_legacy_url_city_district_browse_encode(school_state_name)}/city/#{school_search_result['school_id']}-school"
    {
        :state => school_search_result['state'].upcase,
        :school_name => school_search_result['school_name'],
        :id => school_search_result['school_id'],
        :city_name => school_search_result['city'],
        :url => school_url
    }
  end
end