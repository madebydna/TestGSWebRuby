require 'features/page_objects/modules/footer'
class OspLandingPage < SitePrism::Page

  set_url '/school-accounts/'
  include Footer
end
