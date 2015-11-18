require_relative 'modules/flash_messages'

class ResetPasswordPage < SitePrism::Page
  include FlashMessages

  set_url_matcher /account\/reset-password/

  element :heading, 'h1'
  section :reset_password_form, 'form.rs-reset-password-form' do
    element :password_box, 'input[name="new_password"]'
    element :confirm_password_box, 'input[name="confirm_password"]'
    element :submit_button, 'button', text: 'Submit'
  end

  def fill_in_a_password
    reset_password_form.password_box.set('password')
    reset_password_form.confirm_password_box.set('password')
  end

  def fill_in_a_password_mismatch
    reset_password_form.password_box.set('foo123')
    reset_password_form.confirm_password_box.set('bar123')
  end

  def fill_in_a_too_short_password
    reset_password_form.password_box.set('foo')
    reset_password_form.confirm_password_box.set('foo')
  end

  def click_the_submit_button
    reset_password_form.submit_button.click
  end

end