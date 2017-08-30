class OspModerationController < ApplicationController
  include OspHelper

  STATUS_WHITELIST = %w(approved, rejected, disabled, osp-notes)

  def index
    display_selected_memberships
    @pagination_link_count = membership_size/10 + 1
    render 'osp/osp_moderation/index'
  end

  def update
    member_array = params[:member_array].map {|_, val| [val.first.to_i, val.second]}
    status = params[:status]
    http_status = 200
    if STATUS_WHITELIST.include?(status)
      # If user clicks 'update', only update notes.  Otherwise, update status as well.
      if status == 'osp-notes'
        member_array.each {|member| EspMembership.find(member.first).update(note: member.second)}
      else
        member_array.each {|member| EspMembership.find(member.first).update(note: member.second, status: status)}
      end
    else
      GSLogger.warn(:misc, nil, message: 'Failed to update EspMembership: action not allowed or supported.', vars: {
        params: params
      })
      http_status = 422
    end
    render json: {}, status: http_status
  end

  private

  def fetch_ten_memberships(offset)
    EspMembership.where('status = ? or status = ?', 'provisional', 'processing')
      .offset(offset)
      .limit(10)
      .joins(:user).where('email_verified = ?', true)
      .extend(SchoolAssociationPreloading)
      .preload_associated_schools!
  end

  def membership_size
    @_membership_size ||= EspMembership.where('status = ? or status = ?', 'provisional', 'processing')
                            .joins(:user).where('email_verified = ?', true).size
  end

  def display_selected_memberships
    # This is the main pagination method for this page. It tries to load the right memberships based on the value of
    # params[:start].  If that value is out-of-bounds, it defaults to the first ten memberships.
    if params[:start] && params[:start].to_i.between?(0, membership_size)
      @osp_memberships = fetch_ten_memberships((params[:start].to_i/10)*10)
    else
      @osp_memberships = fetch_ten_memberships(0)
    end
  end

end