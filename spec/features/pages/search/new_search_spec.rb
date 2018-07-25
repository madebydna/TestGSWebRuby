# frozen_string_literal: true

require 'spec_helper'

describe 'New Search' do
  scenario 'is able to visit the page' do
    pending
    visit '/california/alameda/schools/?newsearch'
    expect(page).to have_css('div.search-body')
  end
end
