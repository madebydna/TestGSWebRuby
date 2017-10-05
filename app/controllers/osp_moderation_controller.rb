class OspModerationController < ApplicationController
  include OspHelper
  layout 'admin'
  before_action :set_tags, only: [:index, :osp_search]

  STATUS_WHITELIST = %w(approved rejected disabled osp-notes)
  PARAMS_WHITELIST = %w(state school_id member_id email)

  def index
    display_selected_memberships
    @pagination_link_count = membership_size/10 + 1
    render 'osp/osp_moderation/index'
  end

  def update
    member_array = params[:member_array].values.map {|a| {id: a.first, notes: a.second}}
    status = params[:status]
    http_status = 200
    if STATUS_WHITELIST.include?(status)
      # If user clicks 'update', only update notes.  Otherwise, update status as well.
      member_array.each do |member|
        membership = EspMembership.find(member[:id])
        if status == 'osp-notes'
          membership.update(note: member[:notes])
        else
          # before_save in esp_membership.rb will set active to true if status == 'approved'
          set_active(status)
          membership.update(note: member[:notes], status: status, active: @active)
          membership.approve_provisional_osp_user_data if status == 'approved'
          send_email_to_osp(membership, status)
        end
      end
    else
      GSLogger.warn(:misc, nil, message: 'Failed to update EspMembership: action not allowed or supported.', vars: {
        params: params
      })
      http_status = 422
    end
    render json: {}, status: http_status
  end

  def osp_search
    @permitted_params = request.query_parameters.select{|param, val| PARAMS_WHITELIST.include?(param) && val.present? }.symbolize_keys
    if (@permitted_params[:state] || @permitted_params[:school_id]) && @permitted_params.length <= 1
      # Can't perform search if only state or id (need both)
    elsif @permitted_params.empty?
    elsif @permitted_params[:email]
      if User.where(email: @permitted_params[:email]).present?
        member_id = User.find_by(email: @permitted_params[:email]).id
        @osp_memberships = EspMembership.where(member_id: member_id).where(@permitted_params.except(:email, :member_id))
                           .joins(:user).where('email_verified = ?', true)
                           .extend(SchoolAssociationPreloading)
                           .preload_associated_schools!
      end
    else
      @osp_memberships = EspMembership.where(@permitted_params.except(:email))
                           .extend(SchoolAssociationPreloading)
                           .preload_associated_schools!
    end
    render 'osp/osp_moderation/osp_search'
  end

  def edit
    @osp = EspMembership.where(id: params[:id]).extend(SchoolAssociationPreloading).preload_associated_schools!.take
    @user = User.find(@osp.member_id)
    render '/osp/osp_moderation/edit'
  end

  def update_osp_list_member
    # Need to load associated school in case update fails (and 'edit' template is rendered)
    @osp = EspMembership.where(id: params[:id]).extend(SchoolAssociationPreloading).preload_associated_schools!.take
    @user = User.find(@osp.member_id)
    if @osp.update(osp_params.merge(updated: Time.now)) && @user.update_attributes(user_params)
      redirect_to :back
    else
      render 'osp/osp_moderation/edit'
    end
  end

  private

  def osp_params
    params.require(:esp_membership).permit(:job_title, :web_url, :note)
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name)
  end

  def set_active(status)
    if ['rejected', 'disabled'].include?(status)
      @active = false
    elsif status == 'approved'
      @active = true
    end
  end

  def fetch_one_page_of_memberships(offset)
    EspMembership.where('status = ? or status = ?', 'provisional', 'processing')
      .offset(offset)
      .limit(10)
      .joins(:user).where('email_verified = ?', true)
      .extend(SchoolAssociationPreloading)
      .preload_associated_schools!
  end

  def membership_size
    @_membership_size ||= EspMembership.where('status = ? or status = ?', 'provisional', 'processing')
                            .joins(:user).where('email_verified = ?', true).count
  end

  def display_selected_memberships
    # This is the main pagination method for this page. It tries to load the right memberships based on the value of
    # params[:start].  If that value is out-of-bounds, it defaults to the first ten memberships.
    if params[:start] && params[:start].to_i.between?(0, membership_size)
      @osp_memberships = fetch_one_page_of_memberships((params[:start].to_i/10)*10)
    else
      @osp_memberships = fetch_one_page_of_memberships(0)
    end
  end

  def set_tags
    set_meta_tags title: 'GreatSchools Admin'
  end

end