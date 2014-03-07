module OmnitureConcerns
  include LocalizationConcerns

  protected

  # Make this modules methods into helper methods view can access
  def self.included obj
    return unless obj < ActionController::Base
    (instance_methods - ancestors).each { |m| obj.helper_method m }
  end

  def set_omniture_data_for_school(page_name)
    school_locale = @school.city.nil? ? @school.county : @school.city
    school_level_code = (LevelCode.new(@school.level_code)).levels.map(&:long_name).join('+')
    gon.omniture_sprops ||= {}

    gon.omniture_sprops.merge!({'schoolId' => @school.id, 'schoolType' => @school.type,
                           'schoolLevel' => school_level_code, 'schoolLocale' => school_locale})

    if is_school_for_localized_profiles && !page_name.nil?
      gon.omniture_sprops['localPageName'] = page_name
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
    if !request.query_string.empty?
      gon.omniture_sprops['queryString'] = request.query_string
    end
  end

  def set_omniture_events_in_session(events_array=[])
    props_events_hash = session[:omniture_tracking] || {}
    props_events_hash['events'] ||= []
    props_events_hash['events'] += events_array
    props_events_hash['events'].uniq!

    session[:omniture_tracking] = props_events_hash
  end

  def set_omniture_sprops_in_session(sprops_hash={})
    props_events_hash = session[:omniture_tracking] || {}
    props_events_hash['sprops'] ||= {}
    props_events_hash['sprops'].merge!(sprops_hash)

    session[:omniture_tracking] = props_events_hash
  end

  def read_omniture_data_from_session
    session_value = session[:omniture_tracking]
    gon.omniture_sprops ||= {}
    gon.omniture_events ||= []

    if !session_value.nil?
      props_events_hash = session_value
      if props_events_hash
        sprops_hash = props_events_hash['sprops']
        if sprops_hash && sprops_hash.any?
          gon.omniture_sprops.merge!(sprops_hash)
        end

        events_array = props_events_hash['events']
        if events_array && events_array.any?
          gon.omniture_events += events_array
        end

      end
    end
    session.delete(:omniture_tracking)
  end


end