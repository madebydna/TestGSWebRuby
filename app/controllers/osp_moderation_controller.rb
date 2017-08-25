class OspModerationController < ApplicationController
  include OspModerationHelper

  def index
    # To filter out spam submissions, check that the EspMembership has a user whose password has been set
    # @osp_submissions = EspMembership.where('status = ? or status = ?', 'provisional', 'processing')
    #                      .joins(:user).where('length(password) = 24')
    #                      .extend(SchoolAssociationPreloading)
    #                      .preload_associated_schools!
    @osp_submissions = EspMembership.where('status = ?', 'disabled')
                         .joins(:user).where('length(password) = 24')
                         .extend(SchoolAssociationPreloading)
                         .preload_associated_schools!
    decorate_osp(@osp_submissions)
    @pagination_link_count = @osp_submissions.size/10 + 1
    display_selected_memberships
    render 'osp/osp_moderation/index'
  end

  def update
    # Convert to an array of tuples in format: [id, notes]
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

end