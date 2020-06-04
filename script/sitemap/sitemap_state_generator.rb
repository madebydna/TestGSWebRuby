# frozen_string_literal: true

require_relative 'sitemap_xml_writer'

class SitemapStateGenerator < SitemapXmlWriter
  include Rails.application.routes.url_helpers
  include UrlHelper

  STATE_FREQ = 'monthly'
  STATE_PRIORITY = '0.5'

  PROFILE_FREQ = 'weekly'
  PROFILE_PRIORITY = '1.0'

  DISTRICT_FREQ = 'weekly'
  DISTRICT_PRIORITY = '0.7'

  CITY_FREQ = 'weekly'
  CITY_PRIORITY = '0.8'

  CITY_BROWSE_FREQ = 'weekly'
  CITY_BROWSE_PRIORITY = '0.7'

  def initialize(output_dir, state)
    super(output_dir)
    @state = state
    @root_element = 'urlset'
    @file_path = "sitemap-#{state}.xml"
    @schema = SITEMAP_SCHEMA
  end

  def write_feed
    within_root_node do
      # write state url
      write_state_url unless @state == 'dc'
      # write profile urls
      write_profile_urls
      # write district urls
      write_district_urls
      # write city and city browse urls
      write_city_urls
    end
    close_file
  end

  private

  ##############
  # Generators #
  ##############

  def cities
    City.cities_in_state(@state).reject do |city|
      School.within_city(@state, city.name).count < 3
    end
  end

  def active_schools
    School.on_db(@state.to_sym).active.order(:id)
  end

  def schools_to_no_index
    School.on_db(@state.to_sym).active.joins("JOIN gs_schooldb.reviews r ON r.school_id=school.id AND r.state = '#{@state}'")
              .select("school.*, count(*) AS num_reviews")
              .where("r.active=1")
              .where(level_code: ['p'])
              .where(type: 'private')
              .where("school.manual_edit_date < ?", Time.now - 4.years)
              .group(:id)
              .having("num_reviews < 3")
  end

  def schools
    active_schools - schools_to_no_index
  end

  def districts
    DistrictRecord.by_state(@state).order(:district_id)
  end

  ###########
  # Writers #
  ###########

  def write_state_url
    write_url('https://www.greatschools.org' + state_path(state_params(@state).merge(trailing_slash: true)), STATE_FREQ, STATE_PRIORITY)
  end

  def write_profile_urls
    schools.each do |school|
      write_url('https://www.greatschools.org' + school_path(school, trailing_slash: true), PROFILE_FREQ, PROFILE_PRIORITY)
    end
  end

  def write_city_urls
    cities.each do |city|
      write_url('https://www.greatschools.org' + city_path(city_params(@state, city.name).merge(trailing_slash: true)), CITY_FREQ, CITY_PRIORITY)
      write_url('https://www.greatschools.org' + search_city_browse_path(city_params(@state, city.name).merge(trailing_slash: true)), CITY_BROWSE_FREQ, CITY_BROWSE_PRIORITY)
    end
  end

  def write_district_urls
    districts.each do |district|
      write_url('https://www.greatschools.org' + district_path(district_params(@state, district.city, district.name).merge(trailing_slash: true)), DISTRICT_FREQ, DISTRICT_PRIORITY)
    end
  end
end