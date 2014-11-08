class DistrictsController < ApplicationController
  include SeoHelper
  include MetaTagsHelper
  include AdvertisingHelper
  include HubConcerns
  include GoogleMapConcerns

  before_action :set_city_state
  before_action :set_hub
  before_action :set_login_redirect
  before_action :write_meta_tags

  def show
    gon.pagename = 'DistrictHome'
    @ad_page_name = :State_Home_Standard # TODO verify name to use
    @district = District.find_by_state_and_name(state_param, district_param)

    @nearby_districts = @district.nearby_districts

    @top_schools = top_schools(@district)
    @params_hash = parse_array_query_string(request.query_string)
    @show_ads = false
    ad_setTargeting_through_gon
    prepare_map
    render 'districts/district_home'
  end

  def top_schools(district)
    district_schools = School.on_db(district.state.downcase.to_sym).
      where(district_id: district.id).
      all

    school_metadata = SchoolMetadata.on_db(district.state.downcase.to_sym).
      where(
        school_id: district_schools.map(&:id),
        meta_key: 'overallRating'
      ).to_a

    school_metadata.sort_by! do |metadata|
      metadata.meta_value.to_i
    end
    school_metadata.reverse!

    top_school_ids = school_metadata.take(10).map(&:school_id)
    district_schools.select { |school| top_school_ids.include? school.id }
  end

  def prepare_map
    @map_schools = @top_schools
    mapping_points_through_gon_from_db
    assign_sprite_files_though_gon
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
