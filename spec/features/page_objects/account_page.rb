require 'features/page_objects/modules/footer'
class AccountPage < SitePrism::Page
  include Footer

  set_url_matcher /\/account\/$/

end
