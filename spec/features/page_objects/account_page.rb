require 'features/page_objects/modules/footer'
class AccountPage < SitePrism::Page
  include Footer

  set_url '/account/'

  class EmailContent < SitePrism::Section
    element :mystat_checkbox, 'input[name="mystat"]'
    element :greatnews_checkbox , 'input[name="greatnews"]'
    element :sponsor_checkbox , 'input[name="sponsor"]'
    element :osp_checkbox , 'input[name="osp"]'
    element :osp_parter_promos_checkbox, 'input[name="osp_partner_promos"]'
  end
  
  class EmailSubscriptions < SitePrism::Section
    element :closed_arrow, '.i-32-close-arrow-head'
    element :open_arrow, '.i-32-open-arrow-head'
    section :content, EmailContent, :xpath, './div[2]'
  end

  class GradeLevelContent < SitePrism::Section
    element :pk_checkbox, 'span.grade-level', text: 'PK'
    element :kg_checkbox, 'span.grade-level', text: 'KG'
    element :first_grade_checkbox, 'span.grade-level', text: '1st'
    element :second_grade_checkbox, 'span.grade-level', text: '2nd'
    element :third_grade_checkbox, 'span.grade-level', text: '3rd'
    element :forth_grade_checkbox, 'span.grade-level', text: '4th'
    element :fifth_grade_checkbox, 'span.grade-level', text: '5th'
    element :sixth_grade_checkbox, 'span.grade-level', text: '6th'
    element :seventh_grade_checkbox, 'span.grade-level', text: '7th'
    element :eighth_grade_checkbox, 'span.grade-level', text: '8th'
    element :ninth_grade_checkbox, 'span.grade-level', text: '9th'
    element :tenth_grade_checkbox, 'span.grade-level', text: '10th'
    element :eleventh_grade_checkbox, 'span.grade-level', text: '11th'
    element :twelfth_grade_checkbox, 'span.grade-level', text: '12th'

    def check_or_uncheck_checkbox(type)
      self.send("#{type}_checkbox").find('label').click
    end
    
    def find_input(type)
      self.send("#{type}_checkbox").find('input[type="checkbox"]', visible: false)
    end
  end

  class GradeLevelSubscriptions < SitePrism::Section
    element :closed_arrow, '.i-32-close-arrow-head'
    element :open_arrow, '.i-32-open-arrow-head'
    section :content, GradeLevelContent, '.body'
  end

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

  section :email_subscriptions, EmailSubscriptions, '.drawer', text: /Email Subscriptions/
  section :grade_level_subscriptions, GradeLevelSubscriptions, '.drawer', text: /My Profile/
  section :change_password, ChangePassword, '.drawer', text: /Change Password/
end
