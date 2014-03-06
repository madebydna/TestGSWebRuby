module LocalizationConcerns
  extend ActiveSupport::Concern

  protected

  def set_hub_cookies
    return if @school.nil?

    write_cookie_value :hubState, @school.state.upcase
    write_cookie_value :hubCity, @school.hub_city
    write_cookie_value :ishubUser, 'y' # typo in camel casing needs to be like this to match GSWeb java code

    school_collection = @school.collection

    if school_collection
      write_cookie_value :eduPage, school_collection.has_edu_page?
      write_cookie_value :choosePage, school_collection.has_choose_page?
      write_cookie_value :eventsPage, school_collection.has_events_page?
      write_cookie_value :enrollPage, school_collection.has_enroll_page?
      write_cookie_value :partnerPage, school_collection.has_partner_page?
    end
  end

  def is_school_for_localized_profiles
    @school.collection.nil? ? false : ('detroit'.match /#{@school.collection.name}/i)
  end

end
