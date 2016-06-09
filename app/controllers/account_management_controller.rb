class AccountManagementController < ApplicationController
  protect_from_forgery

  include AccountHelper

  layout 'application'

  before_action :login_required

  def show
    @page_name = 'Account management'
    gon.pagename = @page_name
    # gon.omniture_pagename = 'GS:Admin:MyAccount'
    # User might not have a user_profile row in the db. It might be nil
    @state_locale = state_locale

    if @state_locale.present?
      gon.state_locale_abbr = @state_locale[:short]
    end

    # User might not have a user_profile row in the db. It might be nil
    @city_locale  = @current_user.user_profile.try(:city)

    @school_to_favorite_school = UserFavoriteSchools.new(@current_user).get

    # NOT USED YET - gets subscription status but not for schools
    # @subscriptions = UserSubscriptions.new(@current_user).get

    account_meta_tags('My account')
    set_saved_searches_instance_variables
    @reviews =  current_user.reviews
    @display_grade_level_array = grade_array_pk_to_12
    @selected_grade_level = @current_user.student_grade_levels
  end

  protected

  def set_saved_searches_instance_variables
    @saved_searches = current_user.saved_searches.limit(50).all
  end

end