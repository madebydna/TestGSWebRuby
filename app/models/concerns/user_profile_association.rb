module UserProfileAssociation
  def self.included(base)
    base.class_eval do
      has_one :user_profile, foreign_key: 'member_id'
    end
  end

  def has_active_profile?
    user_profile && user_profile.active?
  end

  def has_inactive_profile?
    user_profile && user_profile.inactive?
  end

  def create_user_profile
    profile = UserProfile.where(member_id: id).first
    if profile.nil?
      begin
        UserProfile.create!(member_id: id, screen_name: "user#{id}", private:true, how:self.how, active: true, state:'ca')
      rescue => e
        log_user_exception(e)
        raise e
      end
    end
  end
end