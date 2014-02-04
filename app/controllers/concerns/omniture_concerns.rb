module OmnitureConcerns

  include LocalizationConcerns

  def set_common_omniture_data
    gon.omniture_hier1 = 'School,SchoolProfileSuite'

    school_locale = @school.city.nil? ? @school.county : @school.city
    school_level_code = (LevelCode.new(@school.level_code)).levels.map(&:long_name).join(',')
    user_login_status = logged_in? ? 'Logged in' : 'Not logged in'
    request_url =  request.original_url[0,request.original_url.index('?').nil? ? request.original_url.length : request.original_url.index('?') ]
    nav_bar_variant = read_cookie_value('ishubUser') == 'y' ? 'N2' : 'PN'

    gon.omniture_sprops = {'school_id' => @school.id, 'school_type' => @school.type,
                           'school_level' => school_level_code, 'school_locale' => school_locale,
                           'school_rating' => @school.school_metadata.overallRating,
                           'user_login_status' => user_login_status,
                           'request_url' => request_url,
                           'nav_bar_variant' => nav_bar_variant}

    if !request.query_string.nil?
      gon.omniture_sprops['query_string'] = request.query_string
    end

    if is_school_for_localized_profiles && !gon.omniture_pagename.nil?
      gon.omniture_sprops['local_page_name'] = gon.omniture_pagename
    end

  end
end