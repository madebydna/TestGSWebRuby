class DistrictsController < ApplicationController
  include SeoHelper
  include MetaTagsHelper
  include AdvertisingHelper
  include HubConcerns

  before_action :set_city_state
  before_action :set_hub
  before_action :set_login_redirect
  before_action :write_meta_tags

  def show
    @ad_page_name = :State_Home_Standard # TODO verify name to use
    @district = District.find_by_state_and_name(state_param, district_param)
    @top_schools = School.on_db(@district.state.downcase.to_sym).all.take(5)
    @params_hash = parse_array_query_string(request.query_string)
    @show_ads = false
    ad_setTargeting_through_gon
    render 'districts/district_home'
  end

  def districts_show_title
    "[???] Schools - ??? State School Ratings - Public and Private"
  end

  def districts_show_description
    "[???] Schools - ??? State School Ratings - Public and Private"
  end

  def districts_show_keywords
    "[???] Schools - ??? State School Ratings - Public and Private"
  end

  def ad_setTargeting_through_gon
    @ad_definition = Advertising.new
    if @show_ads
      set_targeting = gon.ad_set_targeting || {}
      set_targeting['compfilter'] = format_ad_setTargeting((1 + rand(4)).to_s) # 1-4   Allows ad server to serve 1 ad/page when required by adveritiser
      set_targeting['env'] = format_ad_setTargeting(ENV_GLOBAL['advertising_env']) # alpha, dev, product, omega?
      set_targeting['State'] = format_ad_setTargeting(@state[:short].upcase) # abbreviation
      set_targeting['editorial'] = format_ad_setTargeting('FindaSchoo')
      set_targeting['template'] = format_ad_setTargeting("ros") # use this for page name - configured_page_name

      gon.ad_set_targeting = set_targeting
    end
  end

end
