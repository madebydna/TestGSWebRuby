require 'features/page_objects/modules/flash_messages'
require 'features/page_objects/modules/footer'

class JoinPage < SitePrism::Page
  include FlashMessages
  include Footer

  set_url_matcher /\/gsr\/login\//

  element :forgot_password_link, 'a', text: 'Forgot your password?' 


  def click_forgot_password_link 
    forgot_password_link.click 
  end
end
