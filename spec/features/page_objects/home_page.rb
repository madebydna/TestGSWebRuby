require 'features/page_objects/modules/join_modals'
require 'features/page_objects/modules/flash_messages'
require 'features/page_objects/modules/top_nav_section'
require 'features/page_objects/modules/footer'
require 'features/page_objects/modules/modals'

class HomePage < SitePrism::Page
  include TopNavSection
  include Footer
  include Modals

  set_url '/'

  element :header, 'h1', text: 'Guide your child to a great future'
  element :school_search_button, 'form[name=schoolResultsSearchForm] button.search-btn'
  element :search_field, "input[name=locationSearchString]"
  element :gk_link, ".gk_article_dropdown"

  def user_fill_in_school_search
    search_field.set('Alameda high school')
  end

  def click_school_search
    school_search_button.click
  end

  def user_fill_in_article_search
    article_search_field.set('emotional smarts')
  end

  def click_article_search
    article_search_button.click
  end

  def click_dropdown
    gk_link.click
  end

  class GkDropdown < SitePrism::Section
    elements :content_links, 'a'
  end

  section :gk_content_dropdown, GkDropdown, '.gk-dropdown'

end
