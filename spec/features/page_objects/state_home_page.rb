require 'features/page_objects/modules/footer'
class StateHomePage < SitePrism::Page
  include Footer

  set_url '/{state}/'

  element :state_footer, '.js-city-list'

end
