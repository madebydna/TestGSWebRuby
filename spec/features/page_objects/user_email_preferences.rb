class UserEmailPreferencesPage < SitePrism::Page

  element :heading, 'h1', text: 'Manage my email preferences'
  section :preferences_form, 'form' do
    element :submit_button, 'button', text: 'Save my changes'
  end
end
