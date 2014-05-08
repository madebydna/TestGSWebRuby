class HomeController < ApplicationController


  def prototype

    @article_1 = "/assets/article_img.jpg"
    @byline = "By Carol Lloyd"
    @parent_img = "/assets/kitten_tiny.jpg"
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
    #if @school.show_ads
    set_targeting = {}
    # City, compfilter, county, env, gs_rating, level, school_id, State, type, zipcode, district_id, template
    set_targeting['City'] = @school.city
    set_targeting['compfilter'] = 1 + rand(4) # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
    set_targeting['county'] = @school.county # county name?
    set_targeting['env'] = ENV_GLOBAL['advertising_env'] # alpha, dev, product, omega?
    #set_targeting['gs_rating'] = @school.gs_rating
    set_targeting['level'] = @school.level_code # p,e,m,h
    #set_targeting['school_id'] = @school.id
    set_targeting['State'] = @school.state # abbreviation
    #set_targeting['type'] = @school.type  # private, public, charter
    #set_targeting['zipcode'] = @school.zipcode
    #set_targeting['district_id'] = @school.district.present? ? @school.district.FIPScounty : ""
    set_targeting['template'] = "ros" # use this for page name - configured_page_name

    gon.ad_set_targeting = set_targeting
    #end
  end

end
