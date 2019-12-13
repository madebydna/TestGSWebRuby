require 'features/page_objects/modules/footer'
require 'features/page_objects/modules/top_nav_section'

class DistrictBoundariesPage < SitePrism::Page
  include Footer
  include TopNavSection

  set_url '/school-district-boundaries-map/{?query*}'

end
