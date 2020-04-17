class UserSignupController < ApplicationController

  include AccountHelper

  layout 'application'

  def show
    set_meta_tags(
        title: "Sign up for an account | GreatSchools",
        robots: "noindex"
    )
    set_tracking_info
    render 'show'
  end

  def show_spanish
    I18n.locale = 'es'
    show
  end

  def create
    render 'thankyou'
  end

  # def update
  #   UserSubscriptionManager.new(@current_user).update(param_subscriptions)
  #   UserGradeManager.new(@current_user).update(param_grades)
  #   Subscription.where(id: subscription_ids_to_remove, member_id: current_user.id).destroy_all if subscription_ids_to_remove
  #   flash_notice t('controllers.user_email_preferences_controller.success')
  #   redirect_to user_preferences_path
  # end

  def param_grades
    params['grades'] || []
    #['1','2','3','4']
  end

  def param_language
    params['language'] || 'en'
    #['1','2','3','4']
  end

  def param_subscriptions
    params['subscriptions'] || []
  end

  private

  def set_tracking_info
    data_layer_gon_hash[DataLayerConcerns::PAGE_NAME] = 'GS:Email:Signup'
  end
end

