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

end
