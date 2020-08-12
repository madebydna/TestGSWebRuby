module TopNavSection
  class Menu < SitePrism::Section
    element :account_link, :xpath, './ul/li[7]/ul/li[1]/a', visible: false
    element :logout_link, :xpath, './ul/li[7]/ul/li[2]/a', visible: false
    element :signin_link, '.account_nav_out a'
    element :saved_schools_link, 'a.saved-schools-nav'
  end

  def self.included(page_class)
    page_class.class_eval do
      section :top_nav, '.header_un' do
        section :menu, Menu, 'nav'
      end
    end
  end
end
