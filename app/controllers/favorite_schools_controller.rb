class FavoriteSchoolsController < ApplicationController
  include DeferredActionConcerns
  include FavoriteSchoolsConcerns

  def create
    favorite_schools_params = params['favorite_school']

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