module OspModerationHelper

  def display_selected_memberships
    # checking that start parameter is within bounds
    if params[:start] && params[:start].to_i < @osp_submissions.size
      @osp_submissions = @osp_submissions[params[:start].to_i..(params[:start].to_i + 9)]
    else
      @osp_submissions = @osp_submissions[0..9]
    end
  end

  def decorate_osp(osp_membership)
    osp_membership.each do |osp|
      if osp.school && osp.school.cache_results.school_leader_email &&  osp.school.cache_results.school_leader_email == osp.user.email
        osp.instance_variable_set(:@matched_contact, true)
      elsif osp_membership.any? {|osp_sub| osp_sub.school_id == osp.id && osp_sub.state == osp.state && osp_sub.active == true}
        osp.instance_variable_set(:@has_active_memberships, true)
      end
    end
  end

end