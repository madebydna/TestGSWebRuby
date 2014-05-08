class FavoriteSchoolsController < ApplicationController
  include DeferredActionConcerns
  include FavoriteSchoolsConcerns

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
      redirect_back_or_default
    else
      save_deferred_action :add_favorite_school_deferred, favorite_schools_params
      flash_error 'Please log in or register your email to begin tracking your favorite schools.'
      redirect_to signin_url
    end
  end

end