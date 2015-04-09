class SchoolModeratePage < SitePrism::Page
  set_url_matcher /admin\/gsr\/#{States.any_state_name_regex.source}\/schools\/\d+\/moderate\/?/

end