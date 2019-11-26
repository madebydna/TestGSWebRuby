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
      write_state_url
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

  def schools
    School.on_db(@state.to_sym).active.order(:id)
  end

  def districts
    District.on_db(@state.to_sym).active.order(:id)
  end

  ###########
  # Writers #
  ###########

  def write_state_url
    write_url(state_url(state_params(@state)), STATE_FREQ, STATE_PRIORITY)
  end

  def write_profile_urls
    schools.each do |school|
      write_url(school_url(school), PROFILE_FREQ, PROFILE_PRIORITY)
    end
  end

  def write_city_urls
    cities.each do |city|
      write_url(city_url(city_params(@state, city.name)), CITY_FREQ, CITY_PRIORITY)
      write_url(search_city_browse_url(city_params(@state, city.name)), CITY_BROWSE_FREQ, CITY_BROWSE_PRIORITY)
    end
  end

  def write_district_urls
    districts.each do |district|
      write_url(district_url(district_params(@state, district.city, district.name)), DISTRICT_FREQ, DISTRICT_PRIORITY)
    end
  end
end