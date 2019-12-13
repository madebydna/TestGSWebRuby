require 'features/page_objects/modules/join_modals'
require 'features/page_objects/modules/flash_messages'
require 'features/page_objects/modules/breadcrumbs'
require 'features/page_objects/modules/top_rated_schools_section'
require 'features/page_objects/modules/footer'

class CityHomePage < SitePrism::Page
  include EmailJoinModal
  include FlashMessages
  include Breadcrumbs
  include Footer

  set_url '/{state}/{city}/'

  section :top_rated_schools_section, PageObjects::TopRatedSchools::Section, '#top-rated-schools-in-city'

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

  section :city_rating, '.rs-city-rating' do
    element :rating, '.jumbo-text,.jumbo-text-sub'
    def value
      rating.text
    end
    def has_rating?(v)
      value == v
    end
    def not_rated?
      value == 'NR'
    end
  end

  section :largest_districts_section, '#largest-districts-in-city' do
    sections :districts, '.search-result-border' do
      element :district_link, 'a'
      element :city_state, 'span:eq(2)'
      def text
        root_element.text
      end
      def href
        district_link['href']
      end
    end
    define_ordinal_methods(:district, :districts)
  end

  def click_on_preschool_link
    preschool_link.click
  end

end
