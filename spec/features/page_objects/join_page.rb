require 'features/page_objects/modules/flash_messages'

class JoinPage < SitePrism::Page
  include FlashMessages

  set_url_matcher /\/gsr\/login\//

  element :forgot_password_link, 'a', text: 'Forgot your password?' 


  def click_forgot_password_link 
    forgot_password_link.click 
  end
end
