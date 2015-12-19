require 'features/page_objects/modules/breadcrumbs'


class DistrictHomePage < SitePrism::Page
  include Breadcrumbs

  element :email_signup_section, '.js-shared-email-signup'
end