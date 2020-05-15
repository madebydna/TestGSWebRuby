require 'features/page_objects/modules/footer'
class AccountPage < SitePrism::Page
  include Footer

  set_url '/account/'

  class ChangePasswordContent < SitePrism::Section
    element :password_field, 'input#new_password'
    element :password_confirmation_field, 'input#confirm_password'
    element :submit_btn, 'button', text: 'Submit'
    element :confirmation, 'div.modal-body', text: 'Your password has been updated.'
  end

  class ChangePassword < SitePrism::Section
    element :closed_arrow, '.i-32-close-arrow-head'
    element :open_arrow, '.i-32-open-arrow-head'
    section :content, ChangePasswordContent, '.body'
  end

  element :preferences_link, 'a.heading', text: /Email Preferences/
  section :change_password, ChangePassword, '.drawer', text: /Change Password/
end
