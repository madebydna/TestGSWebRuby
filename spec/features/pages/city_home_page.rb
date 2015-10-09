require_relative './modules/email_join_modal'
require_relative './modules/flash_messages'

class CityHomePage < SitePrism::Page
  include EmailJoinModal
  include FlashMessages

  section :email_signup_section, '.js-shared-email-signup' do
    element :submit_button, '.hidden-xs button', text: 'Sign up'
  end


end