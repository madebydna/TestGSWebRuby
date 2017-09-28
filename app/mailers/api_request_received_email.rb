class ApiRequestReceivedEmail < AbstractExactTargetMailer

  self.exact_target_email_key = 'apiWelcomeMessage'
  self.priority = 'Medium'

  def self.deliver_to_api_key_requester(api_account)
    exact_target_email_attributes = {
    }

    deliver(api_account.email, exact_target_email_attributes)
  end

end