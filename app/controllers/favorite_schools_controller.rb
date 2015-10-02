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
        render json: {}
      else
        redirect_back_or_default
      end
    else
      save_deferred_action :add_favorite_school_deferred, favorite_schools_params
      flash_error I18n.t('controllers.favorite_schools_controller.login_required')
      if request.xhr?
        render json: {}, status: 422
      else
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
        message = I18n.t('controllers.favorite_schools_controller.school_removed')
      else
        message = I18n.t('controllers.favorite_schools_controller.school_not_removed_error')
      end
    else
      message = I18n.t('controllers.favorite_schools_controller.school_not_on_list_error')
    end

    @result = {
      success: success,
      message: message
    }
  end

end
