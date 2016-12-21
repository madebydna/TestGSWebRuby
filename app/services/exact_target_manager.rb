class ExactTargetManager

  def contact_status(phone_numbers)
    # sms_rest = SmsRest.new
    # sms_rest.contact_subscriptions(phone_numbers)
  end

  def contact_add(person_info)
    # sms_rest = SmsSoap.new
    # sms_rest.set_data_extension_row(person_info)
  end

  def self.subscriber_get(email)
    # EmailSoap.new.get_subscriber(email)
  end

  def self.subscriber_create(user)
    # EmailSoap.new.create_subscriber(user)
  end

  def self.subscriber_update(user)
    # EmailSoap.new.update_subscriber(user)
  end

  def self.subscriber_delete(email)
    # EmailSoap.new.delete_subscriber(email)
  end
end