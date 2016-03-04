class ExactTargetManager

  def contact_status(phone_numbers)
    sms_rest = SmsRest.new
    sms_rest.contact_subscriptions(phone_numbers)
  end

  def contact_add(person_info)
    sms_rest = SmsSoap.new
    sms_rest.set_data_extension_row(person_info)
  end

end