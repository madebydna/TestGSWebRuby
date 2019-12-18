require 'features/page_objects/modules/flash_messages'
require 'features/page_objects/modules/footer'

class JoinPage < SitePrism::Page
  include FlashMessages
  include Footer

  set_url '/gsr/login/'

  element :signup_link, 'a', text: 'Sign up'
  element :forgot_password_link, 'a', text: 'Forgot your password?' 
  element :facebook_button, 'button.btn-facebook'

  class JoinForm < SitePrism::Section
    element :email_field, 'input#join-email'
    element :signup_btn, 'button.submit'
  end

  section :signup_form, JoinForm, 'form.js-join-form'

  def click_forgot_password_link 
    forgot_password_link.click 
  end
end
