class Admin::ApiUsersController < ApplicationController
  OFFSET = 100

  def index
    @users = selected_api_accounts
  end

  def new
    @api_account = Api::User.new
  end

  def create

  end

  # def create_api_account
  #   @api_account = ApiAccount.new(api_account_params.merge(api_key: nil))
  #   if @api_account.save
  #     ApiRequestReceivedEmail.deliver_to_api_key_requester(@api_account)
  #     ApiRequestToModerateEmail.deliver_to_admin(@api_account)
  #     redirect_to request_api_key_success_path
  #   else
  #     render 'register'
  #   end
  # end

  def edit
  end

  def update
  end

  def user_params
    params.require(:api_account).permit(:id, :first_name, :organization, :email, :website,
                                  :phone, :industry, :intended_use, :type, :account_updated, :email_confirmation)
  end

end