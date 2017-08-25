class OspModerationController < ApplicationController
  include OspModerationHelper

  def index
    # To filter out spam submissions, check that the EspMembership has a user whose password has been set
    @osp_memberships = EspMembership.where('status = ? or status = ?', 'provisional', 'processing')
                         .joins(:user).where('length(password) = 24')
                         .extend(SchoolAssociationPreloading)
                         .preload_associated_schools!
    # @osp_memberships = EspMembership.where('status = ?', 'disabled')
    #                      .joins(:user).where('length(password) = 24')
    #                      .extend(SchoolAssociationPreloading)
    #                      .preload_associated_schools!
    @pagination_link_count = @osp_memberships.size/10 + 1
    display_selected_memberships
    render 'osp/osp_moderation/index'
  end

  def update
    member_array = params[:member_array].map {|_, val| [val.first.to_i, val.second]}
    status = params[:status]
    # If user clicks 'update', only update notes.  Otherwise, update status as well.
    if status == 'osp-notes'
      member_array.each {|member| EspMembership.find(member.first).update(note: member.second)}
    else
      member_array.each {|member| EspMembership.find(member.first).update(note: member.second, status: status)}
    end
    render nothing: true
  end

  private

  def display_selected_memberships
    # checking that start parameter is within bounds
    if params[:start] && params[:start].to_i < @osp_memberships.size
      @osp_memberships = @osp_memberships[params[:start].to_i..(params[:start].to_i + 9)]
    else
      @osp_memberships = @osp_memberships[0..9]
    end
  end

end