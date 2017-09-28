class ApiRequestToModerateEmail < AbstractExactTargetMailer

  self.exact_target_email_key = '2017_API_account_request'
  self.priority = 'High'

  def self.deliver_to_admin(api_account)
    exact_target_email_attributes = {
      API_name: api_account.name,
      API_website: api_account.website,
      API_industry: api_account.industry,
      API_email: api_account.email,
      API_organization: api_account.organization,
      API_intended_use: api_account.intended_use
    }

    deliver('athaler@greatschools.org', exact_target_email_attributes)
  end

end