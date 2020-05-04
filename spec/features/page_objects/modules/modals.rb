module Modals

  class NewsletterModal < SitePrism::Section
    element :email_field, 'input[name=email]'
    elements :grade_buttons, 'span.multi-select-button-group button'
    element :partner_offers_and_updates_checkbox, 'input[name=sponsors_list]'
    element :teacher_checkbox, 'input[name=teacher_list]'
    element :submit_button, 'button[type=submit]'

    def sign_up(email, grades=[2,3], offers: false, teacher: false)
      email_field.set(email)
      grade_buttons_to_click = grade_buttons.select {|btn| grades.include?(btn['data-value'].to_i) }
      grade_buttons_to_click.each {|btn| btn.click }
      partner_offers_and_updates_checkbox.set(offers)
      teacher_checkbox.set(teacher)
      submit_button.click
    end
  end


  def self.included(page_class)
    page_class.class_eval do
      element :modals, '.js-modal-container', visible: true

      def close_all_modals
        page.find('.remodal span.close').click
      end

      section :email_newsletter_modal, NewsletterModal, '.js-modal-container',
        visible: true,
        text: 'Get our best articles, worksheets, and more delivered weekly to your inbox.'

      section :saved_school_modal, NewsletterModal, '.js-email-join-for-school-profile-modal',
        text: 'Saved this school to My School List!'

      element :saved_school_success_modal, '.success-modal', visible: true, text: 'Success!'
      element :newsletter_success_modal, '.success-modal', visible: true, text: 'You\'ve signed up to receive updates'

      section :relationship_to_school_modal, '.js-school-user-modal' do
        element :parent, 'div[data-school-user=parent]'
        element :student, 'div[data-school-user=student]'
        element :pricipal, 'div[data-school-user=pricipal]'
        element :teacher, 'div[data-school-user=teacher]'
        element :community_member, 'div[data-school-user="community member"]'
        element :submit_button, 'button.submit-button'
      end

    end
  end
end
