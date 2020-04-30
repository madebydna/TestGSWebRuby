class UserSignupController < ApplicationController

  include AccountHelper

  layout 'application'

  def show
    show_all
  end

  def show_all
    @page_name = 'User Signup'
    gon.pagename = @page_name
    @grades_hashes = grades_hashes

    account_meta_tags('Sign up for an account')
    set_tracking_info
    render 'show'
  end

  def show_spanish
    I18n.locale = :es
    show_all
  end

  def thankyou
    account_meta_tags('Thank you')
  end

  def create
    # TODO: Verify that account does not exist, then create account and add subscriptions below
    invalid = nil
    user = nil
    if invalid.present?
      set_variables_repopulate_form
      show_all
    else
      UserEmailSubscriptionManager.new(user).update(process_subscriptions(param_subscriptions))
      UserEmailGradeManager.new(user).update(process_grades(param_grades))
      render 'thankyou'
    end
  end

  def set_variables_repopulate_form
    subs = JSON.parse(param_subscriptions).flatten
    @teacher_list = subs.include?('teacher_list')
    @greatnews = subs.include?('greatnews')
    @greatkidsnews = subs.include?('greatkidsnews')
    @sponsor = subs.include?('sponsor')
    @email = params['email']
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

  def grades_hashes
    {
      :en => {
        :overall => create_overall_grades('en')
      },
      :es => {
        :overall => create_overall_grades('es')
      }
    }
  end

  def create_overall_grades(language)
    title = language == 'es' ? 'Grado por grado' : 'Grade by Grade'
    grades_labels = language == 'es' ? available_grades_spanish : available_grades
    path_to_yml = 'lib.user_signup.'

    {
        :active_grades => param_grades,
        :district_state => '',
        :district_id => '',
        :language => language,
        :title => title,
        :subtitle => path_to_yml + "greatkidsnews_subtitle",
        :label => path_to_yml + "select_grades",
        :available_grades => grades_labels
    }
  end

  def process_grades(param_grades)
    parsed_grades = JSON.parse(param_grades)
    parsed_grades.map { |r| [r[0].to_s, r[1], r[2], r[3]] }
  end

  def process_subscriptions(param_subscriptions)
    JSON.parse(param_subscriptions)
  end

  private

  def set_tracking_info
    data_layer_gon_hash[DataLayerConcerns::PAGE_NAME] = 'GS:Email:Signup'
  end
end

