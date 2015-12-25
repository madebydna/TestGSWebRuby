require 'features/page_objects/header_section'
require 'features/page_objects/modules/breadcrumbs'
require 'features/page_objects/modules/gs_rating'

class SchoolProfileQualityPage < SitePrism::Page
  include Breadcrumbs
  include GSRating

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/quality\/(#.*)?/

  element :profile_navigation, '#navigation2'
  section :header, HeaderSection, '.navbar-static'
end
