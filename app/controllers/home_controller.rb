class HomeController < ApplicationController
  protect_from_forgery

  before_action :ad_setTargeting_through_gon
  before_action :data_layer_through_gon
  before_action :set_login_redirect

  layout 'application'

  def show
    @show_ads = PropertyConfig.advertising_enabled?

    @canonical_url = home_url
    # Description lives in view because the meta-tags gem truncates description at 200 chars. See https://github.com/kpumuk/meta-tags
    set_meta_tags title: 'GreatSchools - Public and Private School Ratings, Reviews and Parent Community',
      keywords: 'school ratings, public schools, public school ratings, private schools, private school ratings, charter schools, charter school ratings, school reviews, school rankings, test scores, preschool, elementary school, middle school, high school, parent community, education resource, find school, great schools, greatschools'
    @homepage_banner_prop = PropertyConfig.get_property('homePageGreatKidsMilestoneBannerActive', 'false')
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

  def page_view_metadata
    @page_view_metadata ||= (
    page_view_metadata = {}
    page_view_metadata['page_name']   = 'GS:Home'
    page_view_metadata['compfilter'] = (1 + rand(4)).to_s # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
    page_view_metadata['env']         = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
    page_view_metadata['template']    = 'homepage' # use this for page name - configured_page_name
    page_view_metadata['editorial']   = 'pushdownad'

    page_view_metadata

    )
  end

  def ad_setTargeting_through_gon
    @ad_definition = Advertising.new
      page_view_metadata.each do |key, value|
        ad_targeting_gon_hash[key] = value
      end
  end

  def data_layer_through_gon
    data_layer_gon_hash.merge!(page_view_metadata)
  end

end
