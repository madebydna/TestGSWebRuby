class HomeController < ApplicationController
  protect_from_forgery
  include AdvertisingHelper

  before_action :ad_setTargeting_through_gon
  before_action :set_login_redirect

  layout 'application'

  def prototype

    @canonical_url = home_url
    # Description lives in view because the meta-tags gem truncates description at 200 chars. See https://github.com/kpumuk/meta-tags
    set_meta_tags title: 'GreatSchools - Public and Private School Ratings, Reviews and Parent Community',
      keywords: 'school ratings, public schools, public school ratings, private schools, private school ratings, charter schools, charter school ratings, school reviews, school rankings, test scores, preschool, elementary school, middle school, high school, parent community, education resource, find school, great schools, greatschools'

    set_omniture_pagename
    gon.pagename = "Homepage"
  end

  def set_omniture_pagename
    gon.omniture_pagename = 'GS:Home'
    set_omniture_data(gon.omniture_pagename)
  end

  def set_omniture_data(page_name)
    set_omniture_data_for_user_request
    set_omniture_hier_for_home_page
  end

  def set_omniture_hier_for_home_page
    gon.omniture_hier1 = 'Home,Splash'
  end

  def index_page_publications
    publications = Publication.find_by_ids 1, 23, 45
    @publications = format_publications(publications)
  end

  def format_publications(publications)
    publications.each_value { |pub| pub.create_attributes_for 'title', 'body', 'author' }
    publications
  end

  def ad_setTargeting_through_gon
    @ad_definition = Advertising.new
    #if @school.show_ads
    set_targeting = gon.ad_set_targeting || {}
    # City, compfilter, env,State, type, template
    # set_targeting needs to be a string to work
    set_targeting[ 'compfilter'] = (1 + rand(4)).to_s # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
    set_targeting['env'] = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
    set_targeting['template'] = 'homepage' # use this for page name - configured_page_name
    set_targeting['editorial'] = 'pushdownad'

    gon.ad_set_targeting = set_targeting
    #end
  end

end
