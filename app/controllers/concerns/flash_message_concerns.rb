module FlashMessageConcerns

  protected

  def flash_message(type, message)
    Rails.logger.debug("Setting flash #{type} message: #{message}")
    flash[type] = Array(flash[type])
    if message.is_a? Array
      flash[type] += message
    else
      flash[type] << message
    end
  end

  def flash_error(message)
    flash_message :error, message
  end

  def flash_notice(message)
    flash_message :notice, message
  end

  def flash_success(message)
    flash_message :success, message
  end

  def flash_notice_include?(message)
    flash[:notice].try(:include?, message)
  end

  # delete this (and the before_action call) after the java pages that use the
  # flash_notice_key go away
  def adapt_flash_messages_from_java
    if cookies[:flash_notice_key]
      translated_message = t(read_cookie_value(:flash_notice_key))
      flash_notice(translated_message)
      delete_cookie(:flash_notice_key)
    end
  end

end
