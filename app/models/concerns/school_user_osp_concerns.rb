module SchoolUserOspConcerns
  extend ActiveSupport::Concern

  def esp_memberships
    @esp_memberships ||= user.esp_memberships.for_school(school)
  end

  def provisional_or_approved_osp_user?
    provisional_osp_user? || approved_osp_user?
  end

  def approved_osp_user?
    esp_memberships.any? { |membership| membership.approved? }
  end

  def provisional_osp_user?
    esp_memberships.any? { |membership| membership.provisional? }
  end

end