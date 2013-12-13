class LocalizedProfilePage < GsPage
  elements :navigation, '.nav'

  # When working with LocalizedProfilePage pages, we can use patterns that map to actual URL paths
  # For example, if you need a feature that deals specifically with preschools, this is where you'd add the mapping
  URLS = {
    /^Alameda High School/ => '/california/alameda/1-alameda-high-school',
    /^(a )?high school( page)?/ => '/california/alameda/1-alameda-high-school'
  }

end