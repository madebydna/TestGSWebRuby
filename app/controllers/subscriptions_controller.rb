class SubscriptionsController < ApplicationController
  include PostLoginConcerns

  def create
    list = params[:list]
    raise 'yay!!'

    if logged_in?
      begin
        current_user.add_subscription!(list)
        flash_notice t('actions.review.activated') # TODO
        redirect_to successful_save_redirect(review_params)
      rescue error
        flash_error error
        redirect_to action: :new
      end
    else
      save_post_login_action :add_subscription, params
      # save_review_params
      flash_error 'Please log in or register your email in order to get updates on this school.'
      redirect_to signin_path
    end
  end




end