module Api
  module ErrorHelper
    def error_messages(key, messages)
      return nil unless messages.present?

      errors = messages.map {|message| (key.to_s.capitalize + ' ' + message).humanize}.join(', ')

      raw "<span class='error-message'>#{errors}</span>"
    end
  end
end