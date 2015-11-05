require_relative './modules/email_join_modal'
require_relative './modules/flash_messages'
require_relative './modules/breadcrumbs'


class CityHomePage < SitePrism::Page
  include EmailJoinModal
  include FlashMessages
  include Breadcrumbs

  section :email_signup_section, '.js-shared-email-signup' do
    element :submit_button, '.hidden-xs button', text: 'Sign up'
  end

  element :preschool_link, 'a', text: 'Preschools'
  element :elementary_link, 'a', text: 'Elementary schools'
  element :middle_link, 'a', text: 'Middle schools'
  element :high_link, 'a', text: 'High schools'
  element :public_district_link, 'a', text: 'Public district schools'
  element :private_link, 'a', text: 'Private schools'
  element :public_charter_link, 'a', text: 'Public charter schools'
  element :view_all_link, 'a', text: 'View all schools'
  element :city_rating, '.jumbo-text', text: "4"

  def click_on_preschool_link
    preschool_link.click
  end

end