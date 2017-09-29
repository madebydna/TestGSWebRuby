class OspModerationDecorator < Draper::Decorator
  decorates :esp_membership
  delegate_all

  def matched_contact?
    school && school.cache_results.school_leader_email && school.cache_results.school_leader_email == user.email
  end

  def requesting_multi_access?
    # Conditions: 1) currently evaluating esp_membership is not approved, 2) there is another approved
    # esp_membership with the same member_id
    EspMembership.where(member_id: member_id, status: 'approved').present? && status != 'approved'
  end

  def active_memberships?
    school.claimed? if school
  end

  def highlight_color
    if matched_contact?
      '#D1EFFA'
    elsif requesting_multi_access?
      '#EB6550'
    elsif active_memberships?
      '#ABF293'
    elsif provisional?
      '#F1D472'
    end
  end

end