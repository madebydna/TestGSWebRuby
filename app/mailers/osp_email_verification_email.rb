class OSPEmailVerificationEmail < AbstractExactTargetMailer

  self.exact_target_email_key = 'osp_verification_email'
  self.from = {
      address: 'GreatSchools-Newsletters@email.greatschools.org',
      name: 'GreatSchools'
  }
  self.priority = 'High'

  def self.deliver_to_osp_user(user,verify_link,school)
    exact_target_email_attributes = {
        VERIFICATION_LINK: "<a href=\"#{verify_link}\">#{verify_link}</a>",
        SCHOOL_NAME: school.name,
        FIRST_NAME: user.first_name,
    }

    deliver(user.email, exact_target_email_attributes)
  end

end
