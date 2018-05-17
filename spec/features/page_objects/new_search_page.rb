# frozen_string_literal: true

require 'features/page_objects/modules/footer'

class NewSearchPage < SitePrism::Page
  include Footer

  section :school_list, '.school-list' do
    def number_of_schools
      root_element.find('ol li').to_i
    end
  end
end
