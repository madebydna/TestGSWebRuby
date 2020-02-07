require 'features/page_objects/modules/flash_messages'
require 'features/page_objects/modules/footer'

class ForgotPasswordPage < SitePrism::Page
  include Footer
  include FlashMessages

  set_url '/account/forgot-password/'

  element :email_field, 'input[name="email"]'
  element :continue_button, 'button', text: 'Continue'

  def fill_in_email_field(email)
    email_field.set(email)
  end

  def click_continue_button
    continue_button.click
  end

end
