require 'features/page_objects/modules/flash_messages'

class ForgotPasswordPage < SitePrism::Page
  include FlashMessages

  set_url_matcher /\/account\/forgot-password\//

  element :email_field, 'input[name="email"]'
  element :continue_button, 'button', text: 'Continue'

  def fill_in_email_field(email)
    email_field.set(email)
  end

  def click_continue_button
    continue_button.click
  end

end
