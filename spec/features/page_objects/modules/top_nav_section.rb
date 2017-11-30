module TopNavSection
  def self.included(page_class)
    page_class.class_eval do
      section :top_nav, '.header_un' do
      end
    end
  end
end
