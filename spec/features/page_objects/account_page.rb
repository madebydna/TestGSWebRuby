require 'features/page_objects/modules/footer'
class AccountPage < SitePrism::Page
  include Footer

  set_url '/account/'
  set_url_matcher /\/account\/$/
  
  class EmailSubscriptions < SitePrism::Section
    element :closed_arrow, '.i-32-close-arrow-head'
    element :open_arrow, '.i-32-open-arrow-head'
    element :mystat_checkbox , 'input[name="mystat"]'
    element :greatnews_checkbox , 'input[name="greatnews"]'
    element :sponsor_checkbox , 'input[name="sponsor"]'
  end
  
  section :email_subscriptions, EmailSubscriptions, '.drawer', text: /Email Subscriptions/
end
