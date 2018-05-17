# frozen_string_literal: true

require 'spec_helper'
require 'features/page_objects/new_search_page'

describe 'Visitor', type: :feature, remote: true, safe_for_prod: true do
  subject(:page) { NewSearchPage.new }
  scenario 'sees a list of schools' do
    pending
    visit '/california/alameda/schools/'
    expect(page).to have_school_list
    expect(page.school_list.number_of_schools).to_not eq(0)
  end
end
