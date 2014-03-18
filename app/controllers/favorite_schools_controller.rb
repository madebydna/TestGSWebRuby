class FavoriteSchoolsController < ApplicationController
  include DeferredActionConcerns
  include FavoriteSchoolsConcerns

  def create
    favorite_schools_params = params['favorite_school']

    #Track the start of "add to school list".OM-263
    if favorite_schools_params[:btn_source].present?
      set_omniture_evars_in_session({'review_updates_mss_btn_source' => favorite_schools_params[:btn_source]})
    end
    set_omniture_events_in_session(['review_updates_mss_start_event'])
    set_omniture_sprops_in_session({'custom_completion_sprop' => 'AddToSchoolList'})

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