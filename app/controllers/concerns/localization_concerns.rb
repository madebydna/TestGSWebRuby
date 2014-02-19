module LocalizationConcerns
  extend ActiveSupport::Concern

  def set_hub_cookies
    write_cookie_value :hubState, @school.state.upcase unless @school.nil?
    write_cookie_value :hubCity, @school.hub_city unless @school.nil?
    write_cookie_value :ishubUser, 'y' # typo in camel casing needs to be like this to match GSWeb java code

    write_cookie_value :eduPage, @school.collection.has_edu_page?
    write_cookie_value :choosePage, @school.collection.has_choose_page?
    write_cookie_value :eventsPage, @school.collection.has_events_page?
    write_cookie_value :enrollPage, @school.collection.has_enroll_page?
    write_cookie_value :partnerPage, @school.collection.has_partner_page?
  end

  def is_school_for_localized_profiles
    'detroit'.match /#{@school.collection.name}/i
  end

end
