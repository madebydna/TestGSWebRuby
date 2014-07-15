class AbstractExactTargetMailer

  cattr_accessor :exact_target # Shared by all subclasses
  cattr_accessor :last_triggered_email

  self.exact_target = ExactTarget.new

  class << self
    # Will define class instance methods getters/setters for these attributes
    attr_accessor :exact_target_email_key, :from, :priority
  end

  def self.deliver(recipient, exact_target_email_attributes)
    exact_target.send_triggered_email(
      exact_target_email_key,
      recipient,
      exact_target_email_attributes,
      from,
      priority
    )
  end

end