require_relative '../pages/modules/breadcrumbs'

class CityBrowsePage < SearchPage
  include Breadcrumbs

  elements :school_addresses, '.rs-schoolAddress'

end