require 'addressable/uri'
class EmailCueCardsScenario < AbstractExactTargetMailer

  self.exact_target_email_key = 'email_cue_card'
  self.priority = 'High' # Valid options = Low | Medium | High

  def self.deliver_to_user(email_to, email_from, name_from, scenario, link_url)
    exact_target_email_attributes = {
        cue_card_from_email: email_from,
        cue_card_from_name: name_from,
        cue_card_link: link_url,
        cue_card_content: scenario
    }

    deliver(email_to, exact_target_email_attributes)
  end

end