module FlashMessages
  def self.included(page_class)
    page_class.class_eval do
      elements :flash_messages, '.flash_notice'
      elements :flash_errors, '.flash_error'

      def has_flash_message?(message)
        wait_for_flash_messages
        flash_messages.map do |flash_message_dom_element|
          # The flash message div's text includes the message text plus the "x" button text
          flash_message_dom_element.text.sub(flash_message_dom_element.find('button').text, '')
        end.include?(message)
      end

      def has_flash_error?(message)
        wait_for_flash_errors
        flash_errors.map do |flash_message_dom_element|
          # The flash message div's text includes the message text plus the "x" button text
          flash_message_dom_element.text.sub(flash_message_dom_element.find('button').text, '').strip
        end.include?(message)
      end

    end
  end
end