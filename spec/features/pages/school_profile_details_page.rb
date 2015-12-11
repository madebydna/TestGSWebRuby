require_relative 'header_section'
require_relative './modules/breadcrumbs'
require_relative './modules/gs_rating'

class SchoolProfileDetailsPage < SitePrism::Page
  include Breadcrumbs
  include GSRating

  set_url_matcher /#{States.any_state_name_regex}\/[a-zA-Z\-.]+\/[0-9]+-[a-zA-Z\-.]+\/details\/(#.*)?/

  element :profile_navigation, '#navigation2'
  section :header, HeaderSection, '.navbar-static'
end
