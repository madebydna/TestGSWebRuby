require 'features/page_objects/modules/breadcrumbs'
require 'features/page_objects/modules/top_rated_schools_section'
require 'features/page_objects/modules/footer'

class DistrictHomePage < SitePrism::Page
  include Breadcrumbs
  include Footer

  section :top_rated_schools_section, PageObjects::TopRatedSchools::Section, '#top-rated-schools-in-district'
  element :email_signup_section, '.js-shared-email-signup'
end
