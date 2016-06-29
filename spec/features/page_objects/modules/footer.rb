module Footer 
  def self.included(page_class)
    page_class.class_eval do
      section :footer, '.rs-new-footer' do
      end
    end
  end
end
