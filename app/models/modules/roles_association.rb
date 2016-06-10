module RolesAssociation
  def self.included(base)
    base.class_eval do
      has_many :member_roles, foreign_key: 'member_id'
      has_many :roles, through: :member_roles #Need to use :through in order to use MemberRole model, to specify gs_schooldb
    end
  end

  def has_role?(role)
    member_roles.present? && member_roles.any? { |member_role| member_role.role_id == role.id }
  end

end