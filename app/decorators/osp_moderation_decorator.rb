class OspModerationDecorator < Draper::Decorator
  decorates :esp_membership
  delegate_all

  def matched_contact?
    if school && school.cache_results.school_leader_email && school.cache_results.school_leader_email == user.email
      return true
    end
  end

  def requesting_multi_access?(osp_memberships)
    if osp_memberships.any? {|_osp| _osp.member_id == member_id && _osp.active == true}
      return true
    end
  end

  def active_memberships?(osp_memberships)
    if osp_memberships.any? {|osp_sub| osp_sub.school_id == id && osp_sub.state == state && osp_sub.active}
      return true
    end
  end

  def highlight_color(osp_memberships)
    # Currently a single color is applied to each row
    # This does not address scenarios in which more than one color might be applied
    # For example, it might be good to know that a user has requested multi-access and that the school already has active memberships
    # ...or that a user email matches the contact email but the user is requesting multi-access.
    # Consider using color dots instead of highlighting the entire row.
    if matched_contact?
      return '#D1EFFA'
    elsif requesting_multi_access?(osp_memberships)
      return '#EB6550'
    elsif active_memberships?(osp_memberships)
      return '#ABF293'
    elsif provisional?
      return '#F1D472'
    end
  end

end