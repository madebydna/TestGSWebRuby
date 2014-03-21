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
      flash_error t('actions.review.login_required')
      redirect_to signin_url
    end
  end

  def report
    review_id = params[:reported_entity_id]
    reason = params.fetch(:reported_entity, {})[:reason]

    if review_id.blank? || reason.blank?
      flash_error t('actions.generic_error')
      redirect_back
      return
    end

    if logged_in?
      report_review_and_redirect reported_entity_id: review_id, reason: reason
    else
      save_deferred_action :report_review_deferred, reported_entity_id: review_id, reason: reason
      flash_error t('actions.report_review.login_required')
      redirect_to signin_url
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

    #Track the start of "review a school".OM-263
    if params[:driver].present?
      set_omniture_evars({'review_updates_mss_traffic_driver' => params[:driver]})
      set_omniture_events(['review_updates_mss_start_event'])
      set_omniture_sprops({'custom_completion_sprop' => 'PublishReview'})
    end

  end

  def init_page
    gon.pagename = 'reviews/new'
    @sweepstakes_enabled = PropertyConfig.sweepstakes?
    @google_signed_image = GoogleSignedImages.new @school, gon
    @header_metadata = @school.school_metadata
    @school_reviews_global = SchoolReviews.calc_review_data(@school.reviews)
    @cookiedough = SessionCacheCookie.new cookies[:SESSION_CACHE]

    set_omniture_data
    set_meta_tags :title =>  'Rate and review ' + @school.name + ' in ' + @school.city + ', ' + @school.state
  end

end