class LocalizedProfileController < ApplicationController
  protect_from_forgery

  before_filter :require_state, :require_school
  before_filter :read_config_for_page, except: :reviews
  before_filter :init_page, :set_header_data
  before_filter :store_location, only: [:overview, :quality, :details, :reviews]

  layout 'application'

  def overview
  end

  def quality
  end

  def details
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
    @google_signed_image = GoogleSignedImages.new @school, gon
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
