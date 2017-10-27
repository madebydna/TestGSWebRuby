class OspModerationController < ApplicationController
  include OspHelper
  layout 'admin'

  STATUS_WHITELIST = %w(approved rejected disabled osp-notes)
  PARAMS_WHITELIST = %w(state school_id member_id email)

  def index
    set_tags
    display_selected_memberships
    @pagination_link_count = membership_size/10 + 1
    render '/osp/osp_moderation/index'
  end

  def update
    http_status = 200
    member_array = params[:member_array].values.map {|a| {id: a.first, notes: a.second}}
    if STATUS_WHITELIST.include?(admin_action)
      update_esp_member(member_array)
    else
      GSLogger.warn(:misc, nil, message: 'Failed to update EspMembership: action not allowed or supported.', vars: {
        params: params
      })
      http_status = 422
    end

    render json: {}, status: http_status
  end

  def osp_search
    set_tags
    filter_params
    unless search_id_or_state? && params_count < 2
      fetch_osps
    end

    render '/osp/osp_moderation/osp_search'
  end

  def edit
    fetch_osp_school_user
    render '/osp/osp_moderation/edit'
  end

  def update_osp_list_member
    fetch_osp_school_user
    if osp.update(osp_params.merge(updated: Time.now)) && user.update_attributes(user_params)
      redirect_to :back
    else
      render '/osp/osp_moderation/edit'
    end
  end

  private

  def osp
    @_osp ||= EspMembership.find(params[:id])
  end

  def school
    @_school ||= School.on_db(osp.state.downcase).find(osp.school_id)
  end

  def user
    @_user ||= User.find(osp.member_id)
  end

  def fetch_osp_school_user
    @osp = osp
    @school = school
    @user = user
  end

  def osp_params
    params.require(:esp_membership).permit(:job_title, :web_url, :note)
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name)
  end

  def search_id_or_state?
    filter_params[:state] || filter_params[:school_id]
  end

  def filter_params
    @_filter_params ||= request.query_parameters.select{|param, val| PARAMS_WHITELIST.include?(param) && val.present? }.symbolize_keys
  end

  def search_email?
    filter_params[:email]
  end

  def params_count
    filter_params.length
  end

  def admin_action
    @_admin_action ||= params[:status]
  end

  def active
    @_active ||= (
      if ['rejected', 'disabled'].include?(admin_action)
        false
      elsif admin_action == 'approved'
        true
      end
    )
  end

  def fetch_osps
    email = filter_params[:email]
    search_params = filter_params.except(:email)
    if search_email?
      member = User.find_by(email: email)
      member ? search_params[:member_id] = member.id : search_params.replace({})
    end
    search(search_params) unless search_params.empty?
  end

  def search(search_params)
    @osp_memberships = EspMembership.where(search_params)
                         .extend(SchoolAssociationPreloading)
                         .preload_associated_schools!
  end

  def update_esp_member(member_array)
    # If user clicks 'update', only update notes.  Otherwise, update status as well.
    member_array.each do |member|
      membership = EspMembership.find(member[:id])
      if admin_action == 'osp-notes'
        membership.update(note: member[:notes])
      else
        membership.update(note: member[:notes], status: admin_action, active: active)
        # Handles publication of osp data and email triggers
        post_update(membership)
      end
    end
  end

  def post_update(membership)
    membership.approve_provisional_osp_user_data if admin_action == 'approved'
    send_email_to_osp(membership, admin_action)
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