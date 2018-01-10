module Modals
  def self.included(page_class)
    page_class.class_eval do
      element :modals, '.js-modal-container', visible: true

      def close_all_modals
        page.execute_script('$(".js-modal-container .modal").modal("hide")')
      end
    end

    page_class.class_eval do
      section :email_newsletter_modal, '.js-modal-container', visible: true, text: 'Get our best articles, worksheets, and more delivered weekly to your inbox.' do
        element :email_field, 'input[name=email]'
        element :hidden_grade_field, 'input[name=grades]', visible: false
        element :partner_offers_and_updates_checkbox, 'input[name=sponsors_list]'
        element :submit_button, 'button[type=submit]'

        def sign_up(email, grades=[2,3], offers=true)
          email_field.set(email)
          hidden_grade_field.set(grades.join(','))
          partner_offers_and_updates_checkbox.set(offers)
          submit_button.click
        end
      end
    end

    page_class.class_eval do
      section :newsletter_success_modal, '.success-modal', visible: true, text: 'You\'ve signed up to receive updates' do
      end
    end

  end
end
