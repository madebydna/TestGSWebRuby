require_relative 'modals'

module EmailJoinModal

  class EmailJoinModalSection < SitePrism::Section
    element :email_field, 'input[name=email]'
    element :submit_button, 'button', text: 'Sign up'
    element :sponsors_checkbox, 'input[sponsors_list]'

    def sign_up_with_email(email = 'email@example.com')
      email_field.set(email)
      submit_button.click
    end
  end

  class JoinModalSection < SitePrism::Section
    element :email_field, 'input[name=email]'
    element :password_field, 'input[name=password]'
    element :login_button, :xpath, './/*[@id="login"]/div/form/fieldset[2]/button'
    element :submit_button, 'button', text: 'Sign up'
    element :terms_of_use_checkbox, 'input[terms]'
    element :login_link, 'a', text: 'Log in'

    def sign_up_with_email(email = 'email@example.com')
      email_field.set(email)
      terms_of_use_checkbox.click
      submit_button.click
    end

    def log_in_user(user)
      login_link.click
      email_field.set user.email
      password_field.set user.password
      login_button.click
      sleep(5)
    end
  end

  def self.included(page_class)
    page_class.class_eval do
      include Modals
      section :email_join_modal, EmailJoinModalSection, '.email-join-modal'
      section :join_modal, JoinModalSection, '.js-submit-review-modal, .js-save-search-modal, .js-school-user-modal'
    end
  end
end