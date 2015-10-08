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

  def self.included(page_class)
    page_class.class_eval do
      include Modals
      section :email_join_modal, EmailJoinModalSection, '.email-join-modal'
    end
  end
end