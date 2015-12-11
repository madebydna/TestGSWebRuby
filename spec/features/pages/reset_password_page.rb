require_relative 'modules/flash_messages'

class ResetPasswordPage < SitePrism::Page

  set_url_matcher /account\/password/

  element :heading, 'h2'
  element :passwords_not_match_error, '.parsley-errors-list', text: "This value should be the same."
  element :invalid_password_length_error, '.parsley-errors-list', text: "This value length is invalid. It should be between 6 and 14 characters long."
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
