module TopNavSection
  def self.included(page_class)
    page_class.class_eval do
      section :top_nav, '.navbar.navbar-default.navbar-static' do
        element :my_school_list_link, 'a', text: 'My School List'
      end

      def click_on_my_school_list_link
        top_nav.my_school_list_link.click
      end
    end
  end
end