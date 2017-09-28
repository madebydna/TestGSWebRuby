class NewApiKeyEmail < AbstractExactTargetMailer

  self.exact_target_email_key = 'api_registration_approved'
  self.priority = 'High'

  def self.deliver_to_api_user(api_account)
    exact_target_email_attributes = {
      api_key: api_account.api_key
    }

    deliver(api_account.email, exact_target_email_attributes)
  end

end