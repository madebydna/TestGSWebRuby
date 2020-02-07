module Footer 
  def self.included(page_class)
    page_class.class_eval do
      section :footer, 'footer.rs-new-footer' do
        element :newsletter_link, 'a.js-send-me-updates-button-footer'
      end
    end
  end
end
