module OmnitureConcerns

  include LocalizationConcerns

  def set_omniture_data_for_school
    school_locale = @school.city.nil? ? @school.county : @school.city
    school_level_code = (LevelCode.new(@school.level_code)).levels.map(&:long_name).join('+')
    gon.omniture_sprops ||= {}

    gon.omniture_sprops.merge!({'schoolId' => @school.id, 'schoolType' => @school.type,
                           'schoolLevel' => school_level_code, 'schoolLocale' => school_locale})

    if is_school_for_localized_profiles && !gon.omniture_pagename.nil?
      gon.omniture_sprops['localPageName'] = gon.omniture_pagename
    end

    if !@school.school_metadata.overallRating.nil?
      gon.omniture_sprops['schoolRating'] = @school.school_metadata.overallRating
    end

    gon.omniture_school_state = @school.state
  end

  def set_omniture_hier_for_new_profiles
    gon.omniture_hier1 = 'School,SchoolProfileSuite'
  end

  def set_omniture_data_for_user_request
    user_login_status = logged_in? ? 'Logged in' : 'Not logged in'
    request_url = request.original_url[0, request.original_url.index('?').nil? ? request.original_url.length : request.original_url.index('?')]
    nav_bar_variant = read_cookie_value('ishubUser') == 'y' ? 'N2' : 'PN'

    gon.omniture_sprops ||= {}
    gon.omniture_sprops.merge!({'userLoginStatus' => user_login_status,
                                'requestUrl' => request_url,
                                'navBarVariant' => nav_bar_variant})

    if !request.query_string.nil?
      gon.omniture_sprops['queryString'] = request.query_string
    end
  end


end