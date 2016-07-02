require 'features/page_objects/modules/join_modals'
require 'features/page_objects/modules/flash_messages'
require 'features/page_objects/modules/top_nav_section'

class HomePage < SitePrism::Page

  set_url_matcher /localhost:\d+\/$/

  element :header, 'h1', text: 'Guide your child to a great future'
  element :school_search_button, 'button.pull-right.btn.btn-primary'
  element :school_search_field, "input#js-schoolResultsSearch"

  def user_fill_in_school_search
    school_search_field.set('Alameda high school')
  end

  def click_search
    school_search_button.click
  end

end
