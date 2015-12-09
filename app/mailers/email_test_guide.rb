require 'addressable/uri'
class EmailTestGuide < AbstractExactTargetMailer

  self.exact_target_email_key = 'email_test_guide'
  self.priority = 'High' # Valid options = Low | Medium | High

  def self.deliver_to_user(email_to, email_from, name_from, state, grade, link_url, test_type)
    exact_target_email_attributes = {
        state_test_guide_from_email: email_from,
        state_test_guide_from_name: name_from,
        state_test_guide_state: state,
        state_test_guide_grade: grade,
        state_test_guide_link: link_url,
        state_test_guide_type: test_type
        # EMAIL_FROM: email_from,
        # NAME_FROM: name_from,
        # STATE: state,
        # GRADE: grade,
        # LINK_URL: link_url,
        # TEST_TYPE: test_type
    }

    deliver(email_to, exact_target_email_attributes)
  end

end