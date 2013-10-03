class LocalizedProfilePage < GsPage
  element :navigation, :xpath, '/html/body/nav/div[2]/ul'

  URLS = {
    /^Alameda High School/ => '/california/alameda/1-alameda-high-school',
    /^(a )?high school( page)?/ => '/california/alameda/1-alameda-high-school'
  }

end