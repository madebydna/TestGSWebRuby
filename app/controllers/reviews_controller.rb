class ReviewsController < ApplicationController
  include ReviewControllerConcerns

  before_filter :authenticate_user!, only: [:create]

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
            redirect_to(
              successful_save_redirect(review_params),
              :notice => 'Sweet, your list has been created.'
            )
          }
        else
        end
      end
    else
      save_review_params
      store_location(successful_save_redirect(review_params))
      redirect_to signin_path
    end
  end


end