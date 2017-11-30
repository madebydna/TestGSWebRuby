require 'features/page_objects/modules/footer'

class UserEmailPreferencesPage < SitePrism::Page
  include Footer

  set_url_matcher /\/preferences/

  element :heading, 'h1', text: 'Manage your email preferences'
  section :preferences_form, '.rs-preferences-form' do
    element :submit_button, 'button', text: 'Save changes'
  end

end
