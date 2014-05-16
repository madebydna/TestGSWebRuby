module OmnitureConcerns
  include LocalizationConcerns

  protected

  # Make this modules methods into helper methods view can access
  def self.included obj
    return unless obj < ActionController::Base
    (instance_methods - ancestors).each { |m| obj.helper_method m }
  end

  OMNITURE_COOKIE_NAME = 'OmnitureTracking';

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

    gon.omniture_sprops ||= {}
    gon.omniture_sprops.merge!({'userLoginStatus' => user_login_status,
                                'requestUrl' => request_url,
                                'navBarVariant' => 'N2'})
    if !request.query_string.empty?
      gon.omniture_sprops['queryString'] = request.query_string
    end
  end

  def set_omniture_events(events_array=[])
    gon.omniture_events ||= []
    if events_array && events_array.any?
      gon.omniture_events += events_array
    end
  end

  def set_omniture_sprops(sprops_hash={})
    gon.omniture_sprops ||= {}
    if sprops_hash && sprops_hash.any?
      gon.omniture_sprops.merge!(sprops_hash)
    end
  end

  def set_omniture_evars(evars_hash={})
    gon.omniture_evars ||= {}
    if evars_hash && evars_hash.any?
      gon.omniture_evars.merge!(evars_hash)
    end
  end

  #Use cookies to store the omniture events when they need to be tracked on the following page.
  def set_omniture_events_in_cookie(events_array=[])
    events = read_cookie_value(:"#{OMNITURE_COOKIE_NAME}",'events') || []
    events += events_array
    events.uniq!
    write_cookie_value(:"#{OMNITURE_COOKIE_NAME}", events,'events')
  end

  #Use cookies to store the omniture sprops and evars when they need to be tracked on the following page.
  [:sprops, :evars].each do |var_name|
    method_name = "set_omniture_#{var_name}_in_cookie".to_sym
    define_method method_name do |hash={}|
      omniture_variable = (read_cookie_value(:"#{OMNITURE_COOKIE_NAME}", var_name.to_s)) || {}
      omniture_variable.merge!(hash)
      write_cookie_value(:"#{OMNITURE_COOKIE_NAME}", omniture_variable,var_name.to_s)
    end
    OmnitureConcerns.send :protected, method_name
  end

end

