class Admin::ApiAccountsController < ApplicationController
  before_action :find_account, only: [:edit, :update, :destroy, :create_api_key]
  layout false

  def index
    @api_accounts = ApiAccount.all
  end

  def create
    @api_account = ApiAccount.new(api_account_params)
    if @api_account.save
      redirect_to edit_admin_api_account_path(@api_account)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @api_account.update_attributes(api_account_params.merge({account_updated: Time.now}))
      redirect_to edit_admin_api_account_path(@api_account)
    else
      render 'edit'
    end
  end

  def new
    @api_account = ApiAccount.new
  end

  def destroy
    @api_account.destroy
    redirect_to admin_api_accounts_path
  end

  def create_api_key
    prior_key = @api_account.api_key
    NewApiKeyEmail.deliver_to_api_user(@api_account) if prior_key.nil?
    @api_account.save_unique_api_key
    render json: { apiKey: @api_account.api_key}
  end

  private

  def find_account
    @api_account = ApiAccount.find(params[:id])
  end

  def api_account_params
    params.require(:api_account).permit(:name, :organization, :email, :website,
                                  :phone, :industry, :intended_use, :type, :account_updated)
  end

end