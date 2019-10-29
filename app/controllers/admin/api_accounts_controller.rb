class Admin::ApiAccountsController < ApplicationController
  before_action :find_account, only: [:edit, :update, :destroy, :create_api_key]
  layout 'admin'

  OFFSET = 100

  def index
    @api_accounts = selected_api_accounts
    @pagination_link_count = api_account_size/OFFSET + 1
  end

  def new
    @api_account = ApiAccount.new
  end

  # Handles admin-initiated api account creation
  def create
    @api_account = ApiAccount.new(api_account_params.merge(api_key: nil))
    if @api_account.save
      handle_api_options
      redirect_to edit_admin_api_account_path(@api_account)
    else
      render 'new'
    end
  end

  # Handles user-initiated api account creation
  def create_api_account
    @api_account = ApiAccount.new(api_account_params.merge(api_key: nil))
    if @api_account.save
      ApiRequestReceivedEmail.deliver_to_api_key_requester(@api_account)
      ApiRequestToModerateEmail.deliver_to_admin(@api_account)
      redirect_to request_api_key_success_path
    else
      render 'register'
    end
  end

  def edit
    @api_opts = @api_account.api_config.value if @api_account.api_config
  end

  def update
    if params[:delete_key]
      delete_api_key && return
    end
    if @api_account.update_attributes(api_account_params.merge({account_updated: Time.now}))
      handle_api_options
      redirect_to edit_admin_api_account_path(@api_account)
    else
      render 'edit'
    end
  end

  def register
    build_gon_object
    @api_account = ApiAccount.new
  end

  def success
  end

  def delete_api_key
    @api_account.update(api_key: nil, type: 'f')
    @api_account.delete_api_config
    redirect_to admin_api_accounts_path
  end

  def create_api_key
    @api_account.save_unique_api_key
    # NewApiKeyEmail.deliver_to_api_user(@api_account)
    render json: { apiKey: @api_account.api_key}
  end

  private

  def build_gon_object
    data_layer_gon_hash.merge!({ 'page_name' => 'GS:API:LandingPage', 'GS User Type' => 'API' })
  end

  def find_account
    @api_account = ApiAccount.find(params[:id])
  end

  def api_account_params
    params.require(:api_account).permit(:id, :name, :organization, :email, :website,
                                  :phone, :industry, :intended_use, :type, :account_updated, :email_confirmation)
  end

  def handle_api_options
    api_opts = params[:api_account][:api_options]
    if api_opts && @api_account.api_config
      @api_account.api_config.update(value: api_opts)
    elsif api_opts
      @api_account.build_api_config(account_id: @api_account.id, value: api_opts, name: 'premium_options').save!
    end
  end

  def fetch_one_page_of_api_accounts(offset)
    ApiAccount.offset(offset).limit(OFFSET)
  end

  def api_account_size
    @_membership_size ||= ApiAccount.count
  end

  def selected_api_accounts
    # This is the main pagination method for this page. It tries to load the right api accounts based on the value of
    # params[:start].  If that value is out-of-bounds, it defaults to the first 100 accounts. ?all=true loads everything
    if params[:all] == 'true'
      ApiAccount.all
    elsif params[:start] && params[:start].to_i.between?(0, api_account_size)
      fetch_one_page_of_api_accounts((params[:start].to_i/OFFSET)*OFFSET)
    else
      fetch_one_page_of_api_accounts(0)
    end
  end

end