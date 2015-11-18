class ResetPasswordPage < SitePrism::Page

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

  def click_the_submit_button
    reset_password_form.submit_button.click
  end

end