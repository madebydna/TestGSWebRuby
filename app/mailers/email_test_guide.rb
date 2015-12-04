require 'addressable/uri'
class EmailTestGuide < AbstractExactTargetMailer

  self.exact_target_email_key = 'email_test_guide'
  self.priority = 'High' # Valid options = Low | Medium | High

  def self.deliver_to_user(email_to, email_from, state, grade, url, test_type)
    exact_target_email_attributes = {
        EMAIL_FROM: email_from,
        STATE: state,
        GRADE: grade,
        URL: url,
        TEST_TYPE: test_type
    }

    deliver(email_to, exact_target_email_attributes)
  end

end