class ReviewsController < ApplicationController
  include ReviewControllerConcerns
  include DeferredActionConcerns
  include LocalizationConcerns

  # Find school before executing culture action
  before_filter :require_state, :require_school, :find_user, except: :create
  before_filter :store_location, only: [:overview, :quality, :details, :reviews]
  before_filter :set_last_school_visited, only: [:new]
  before_filter :set_hub_cookies

  def new
    init_page
  end

  def create
    review_params = params[:school_rating]

    if logged_in?
      save_review_and_redirect review_params
    else
      save_deferred_action :save_review_deferred, review_params
      flash_error 'You need to log in or register your email in order to post a review.'
      redirect_to signin_path
    end
  end

  def find_user
    @user_first_name = current_user.first_name unless !logged_in?
  end

  def init_page
    gon.pagename = 'reviews/new'
    @google_signed_image = GoogleSignedImages.new @school, gon
    @header_metadata = @school.school_metadata
    @school_reviews_global = SchoolReviews.set_reviews_objects @school
    @cookiedough = SessionCacheCookie.new cookies[:SESSION_CACHE]
  end

end