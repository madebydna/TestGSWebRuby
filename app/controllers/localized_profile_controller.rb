class LocalizedProfileController < ApplicationController
  protect_from_forgery

  include LocalizationConcerns

  before_filter :require_state, :require_school
  before_filter :read_config_for_page, except: :reviews
  before_filter :init_page, :set_header_data
  before_filter :store_location, only: [:overview, :quality, :details, :reviews]
  before_filter :set_last_school_visited, only: [:overview, :quality, :details, :reviews]
  before_filter :set_hub_cookies

  layout 'application'

  def overview
  end

  def quality
  end

  def details
    gon.omniture_pagename = "details"
    gon.omniture_heirarchy = "details,heirarchy"
    gon.omniture_sprops = {"some_sprop" => "details","some_sprop_test" =>"detailstest"}
    gon.omniture_evars = {"some_evars" => "details","some_evars_test" =>"detailstest"}
  end

  def reviews
    @school_reviews = @school.reviews_filter quantity_to_return: 10

    @review_offset = 0
    @review_limit = 10
  end


  private

  def init_page
    @google_signed_image = GoogleSignedImages.new @school, gon
    gon.pagename = configured_page_name
    gon.omniture_account = ENV_GLOBAL['omniture_account']
    gon.omniture_server = ENV_GLOBAL['omniture_server']
    @cookiedough = SessionCacheCookie.new cookies[:SESSION_CACHE]
  end

  def read_config_for_page
    @page_config = PageConfig.new configured_page_name, @school
  end

  def set_header_data
    @header_metadata = @school.school_metadata
    @school_reviews_global = SchoolReviews.set_reviews_objects @school
  end

  # get Page name in PageConfig, based on current controller action
  def configured_page_name
    # i.e. 'School stats' in page config means this controller needs a 'school_stats' action
    action_name.gsub(' ', '_').capitalize
  end
end
