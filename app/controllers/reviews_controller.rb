class ReviewsController < ApplicationController
  include ReviewControllerConcerns

  # Find school before executing culture action
  before_filter :require_state, :require_school, :find_user, except: :create

  def new
    init_page
  end


  # TODO: Remove these two methods to dry up code
  def serialize_param(path)
    path.gsub(/\s+/, '-')
  end
  def school_params(school)
    {
      state: serialize_param(school.state_name.downcase),
      city: serialize_param(school.city.downcase),
      schoolId: school.id,
      school_name: serialize_param(school.name.downcase)
    }
  end

  def create
    review_params = params[:school_rating]

    if logged_in?
      respond_to do |format|
        if save_review(review_params)
          format.html {
            flash_notice 'Thanks for your school review! Your feedback helps other parents choose the right schools!'
            redirect_to successful_save_redirect(review_params)
          }
        else
          # TODO: handle failure
        end
      end
    else
      save_review_params
      store_location(successful_save_redirect(review_params))
      flash_error 'You need to log in or register your email in order to post a review.'
      redirect_to signin_path
    end
  end

  def find_user
    @user_first_name = current_user.first_name unless !logged_in?
  end

  def init_page
    @header_metadata = @school.school_metadata
    @school_reviews_global = SchoolReviews.set_reviews_objects @school
    @cookiedough = SessionCacheCookie.new cookies[:SESSION_CACHE]
  end

end