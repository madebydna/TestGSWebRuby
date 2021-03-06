# frozen_string_literal: true

require 'features/page_objects/modules/footer'

class ComparePage < SitePrism::Page
  include Footer

  set_url_matcher /\/compare\?/

  section :school_table, 'section.school-table' do
    element :pinned_school,  '.school.pinned'
    element :first_non_pinned_school, 'tbody tr:nth-child(2)'
  end
end
