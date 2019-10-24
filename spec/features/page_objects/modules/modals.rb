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
        elements :grade_buttons, 'span.multi-select-button-group button'
        element :partner_offers_and_updates_checkbox, 'input[name=sponsors_list]'
        element :submit_button, 'button[type=submit]'

        def sign_up(email, grades=[2,3], offers=true)
          email_field.set(email)
          grade_buttons_to_click = grade_buttons.select {|btn| grades.include?(btn['data-value'].to_i) }
          grade_buttons_to_click.each {|btn| btn.click }
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
