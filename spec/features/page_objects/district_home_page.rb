require 'features/page_objects/modules/breadcrumbs'
require 'features/page_objects/modules/top_rated_schools_section'


class DistrictHomePage < SitePrism::Page
  include Breadcrumbs

  section :top_rated_schools_section, PageObjects::TopRatedSchools::Section, '#top-rated-schools-in-district'
  element :district_link, 'a', text: 'District website'

  element :email_signup_section, '.js-shared-email-signup'
end