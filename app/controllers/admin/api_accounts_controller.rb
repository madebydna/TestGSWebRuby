class Admin::ApiAccountsController < ApplicationController
  before_action :find_account, only: [:edit, :update, :destroy, :create_api_key]
  layout 'admin'

  def index
    display_selected_api_accounts
    @pagination_link_count = api_account_size/100 + 1
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
    @api_account.update(api_key: nil)
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

  def fetch_one_page_of_api_accounts(offset)
    ApiAccount.offset(offset).limit(100)
  end

  def api_account_size
    @_membership_size ||= ApiAccount.count
  end

  def display_selected_api_accounts
    # This is the main pagination method for this page. It tries to load the right api accounts based on the value of
    # params[:start].  If that value is out-of-bounds, it defaults to the first 100 accounts.
    if params[:start] && params[:start].to_i.between?(0, api_account_size)
      @api_accounts = fetch_one_page_of_api_accounts((params[:start].to_i/100)*100)
    else
      @api_accounts = fetch_one_page_of_api_accounts(0)
    end
  end

end