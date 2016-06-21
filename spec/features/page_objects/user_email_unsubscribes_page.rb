require 'features/page_objects/modules/flash_messages'

class UserEmailUnsubscribesPage < SitePrism::Page
  include FlashMessages

  set_url_matcher /\/unsubscribe/

  element :unsubscribe,'button', text: 'Unsubscribe'
  element :manage_preferences, 'a', text: 'Manage your email preferences.'

  def unsubscribe_from_emails
    unsubscribe.click
  end

  def click_manage_preferences
    manage_preferences.click
  end
end
