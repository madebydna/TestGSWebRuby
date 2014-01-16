module LocalizationConcerns
  extend ActiveSupport::Concern

  def set_hub_cookies
    write_cookie_value :hubState, @school.state.upcase
    write_cookie_value :hubCity, @school.city
    write_cookie_value :ishubUser, 'y' # typo in camel casing needs to be like this to match GSWeb java code
  end

end
