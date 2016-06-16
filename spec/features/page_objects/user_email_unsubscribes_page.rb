require 'features/page_objects/modules/flash_messages'

class UserEmailUnsubscribesPage < SitePrism::Page
  include FlashMessages

  set_url_matcher /\/unsubscribe/

  element :unsubscribe,'button', text: 'Unsubscribe'
  element :manage_preferences, 'a', text: 'Manage preferences'

  def unsubscribe_from_emails
    unsubscribe.click
  end

end
