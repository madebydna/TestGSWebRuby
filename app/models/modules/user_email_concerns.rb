module UserEmailConcerns
  extend ActiveSupport::Concern

  def send_thank_you_email_for_school(school)
    UserEmailSender.new(self).send_thank_you_email_for_school(school)
  end

end