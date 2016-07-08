require 'features/page_objects/modules/footer'
class StateHomePage < SitePrism::Page
  include Footer

  element :state_footer, '.js-city-list'

end
