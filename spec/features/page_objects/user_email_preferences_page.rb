require 'features/page_objects/modules/footer'

class UserEmailPreferencesPage < SitePrism::Page
  include Footer

  set_url_matcher /\/preferences/

  element :heading, 'h1', text: 'Manage my email preferences'
  section :preferences_form, 'form' do
    element :submit_button, 'button', text: 'Save my changes'
  end

end
