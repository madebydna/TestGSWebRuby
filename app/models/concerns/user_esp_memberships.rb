module UserEspMemberships
  def self.included(base)
    base.class_eval do
      has_many :esp_memberships, foreign_key: 'member_id'
    end
  end

  def provisional_or_approved_osp_user?(school = nil)
    memberships = self.esp_memberships
    memberships = memberships.for_school(school) if school
    memberships.any? { |membership| membership.approved? || membership.provisional? }
  end

  def esp_membership_for_school(school = nil) #always returns membership if user is a superuser
    return esp_memberships.first if is_esp_superuser?
    school.present? ? esp_memberships.for_school(school).first : nil
  end

  def is_esp_superuser?
    has_role?(Role.esp_superuser)
  end

  def is_active_esp_member?
    esp_memberships.approved_or_provisional.active.present? || is_esp_superuser?
  end

  def is_esp_demigod?
    if esp_memberships.count > 1
      true
    else
      false
    end
  end

end