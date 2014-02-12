class ReviewsController < ApplicationController
  include ReviewControllerConcerns
  include DeferredActionConcerns
  include LocalizationConcerns
  include OmnitureConcerns

  # Find school before executing culture action
  before_filter :require_state, :require_school, :find_user, except: [:create, :report]
  before_filter :store_location, only: [:overview, :quality, :details, :reviews]
  before_filter :set_last_school_visited, only: [:new]
  before_filter :set_hub_cookies, only: :new

  def new
    init_page
    set_meta_tags :robots => 'noindex'
  end

  def create
    review_params = params[:school_rating]

    if logged_in?
      save_review_and_redirect review_params
    else
      save_deferred_action :save_review_deferred, review_params
      flash_error 'You need to log in or register your email in order to post a review.'
      redirect_to signin_url
    end
  end

  def report
    begin
      review_id = params[:reported_entity_id]
      reported_entity = params[:reported_entity]
      reason = params[:reported_entity][:reason] if reported_entity
      review = SchoolRating.find review_id rescue nil
      # if review && logged_in?
        reported_entity = ReportedEntity.from_review review, reason
        reported_entity.reporter_id = current_user.id if logged_in?
        reported_entity.save!
      # end
      respond_to do |format|
        format.json  { render :json => { success: true, reason: reason } }
      end
    rescue
      respond_to do |format|
        format.json  { render :json => { success: false }, status: 422 }
      end
    end
  end

  def find_user
    @user_first_name = current_user.first_name unless !logged_in?
  end

  def set_omniture_data
    #Set the pagename before setting other omniture props.
    gon.omniture_pagename = 'GS:SchoolProfiles:WriteAReview'
    set_omniture_hier_for_new_profiles
    set_omniture_data_for_school(gon.omniture_pagename)
    set_omniture_data_for_user_request
  end

  def init_page
    gon.pagename = 'reviews/new'
    @google_signed_image = GoogleSignedImages.new @school, gon
    @header_metadata = @school.school_metadata
    @school_reviews_global = SchoolReviews.set_reviews_objects @school
    @cookiedough = SessionCacheCookie.new cookies[:SESSION_CACHE]

    set_omniture_data
    set_meta_tags :title =>  'Rate and review ' + @school.name + ' in ' + @school.city + ', ' + @school.state
  end

end