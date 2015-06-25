class FavoriteSchoolsController < ApplicationController
  include DeferredActionConcerns
  include FavoriteSchoolsConcerns

  before_action :login_required, only: [:destroy]

  def create
    favorite_schools_params = params['favorite_school']

    #Track the start of "add to school list".OM-263
    if favorite_schools_params[:driver].present?
      set_omniture_evars_in_cookie({'review_updates_mss_traffic_driver' => favorite_schools_params[:driver]})
    end
    set_omniture_events_in_cookie(['review_updates_mss_start_event'])
    set_omniture_sprops_in_cookie({'custom_completion_sprop' => 'AddToSchoolList'})

    if logged_in?
      add_favorite_school favorite_schools_params
      create_subscription favorite_schools_params
      if request.xhr?
        render 'create', status: 200
      else
        redirect_back_or_default
      end
    else
      save_deferred_action :add_favorite_school_deferred, favorite_schools_params
      if request.xhr?
        render 'create', status: 422
      else
        flash_error 'Please log in or register your email to begin tracking your favorite schools.'
        redirect_to signin_url
      end
    end
  end

  def destroy
    @favorite_school = FavoriteSchool.find(params[:id]) rescue nil
    success = false
    message = ''

    if @favorite_school && @current_user.id == @favorite_school.member_id
      success = !!@favorite_school.destroy
      if success
        message = 'School has been removed from your school list'
      else
        message = 'A problem occurred when removing the school from your school list. Please try again later.'
      end
    else
      message = 'The given school was not on your school list'
    end

    @result = {
      success: success,
      message: message
    }
  end

end
