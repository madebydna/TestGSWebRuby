require 'features/page_objects/modules/flash_messages'
require 'features/page_objects/modules/footer'

class UserEmailUnsubscribesPage < SitePrism::Page
  include FlashMessages
  include Footer

  set_url_matcher /\/unsubscribe/

  element :unsubscribe,'button', text: 'Unsubscribe'
  element :manage_preferences, 'a', text: 'Manage your newsletter preferences.'

  def unsubscribe_from_emails
    unsubscribe.click
  end

  def click_manage_preferences
    manage_preferences.click
  end
end
