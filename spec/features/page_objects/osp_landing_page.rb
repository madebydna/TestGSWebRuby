require 'features/page_objects/modules/footer'
class OspLandingPage < SitePrism::Page

  set_url '/official-school-profile/'
  include Footer
end
