# require 'features/page_objects/header_section'
# require 'features/page_objects/modules/breadcrumbs'
# require 'features/page_objects/modules/gs_rating'
# require 'features/page_objects/modules/modals'
# require 'features/page_objects/modules/school_profile_page'

class SchoolProfilePage < SitePrism::Page
  # include Breadcrumbs
  # include GSRating
  # include Modals

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/$/

  element :gs_rating, '.rs-gs-rating'

end
