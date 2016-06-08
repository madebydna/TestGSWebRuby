class UserEmailPreferencesController < ApplicationController
  protect_from_forgery

  include AccountHelper

  layout 'application'

  before_action :login_required

  def show
    @page_name = 'User Email Preferences'
    gon.pagename = @page_name
    # User might not have a user_profile row in the db. It might be nil
    # @state_locale = state_locale

    # gon.state_locale_abbr = @state_locale[:short]

    # @city_locale  = @current_user.user_profile.try(:city)

    # @school_to_favorite_school = UserFavoriteSchools.new(@current_user).get
    @subscriptions = UserSubscriptions.new(@current_user).get

    account_meta_tags
    # set_saved_searches_instance_variables
    # @reviews =  current_user.reviews
    @display_grade_level_array = grade_array_pk_to_8
    @selected_grade_level = @current_user.student_grade_levels
  end

  def account_meta_tags
    set_meta_tags :title => "My email preferences | GreatSchools",
                  :robots => "noindex"
  end

    # protected
    #
    # def set_saved_searches_instance_variables
    #   @saved_searches = current_user.saved_searches.limit(50).all
    # end


end