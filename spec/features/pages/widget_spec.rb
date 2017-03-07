require 'spec_helper'

describe 'widget' do
  before { visit '/widget/' }

  it 'shows the right title' do
    expect(page).to have_selector('title', text: 'GreatSchools School Finder Widget | GreatSchools', visible: false)
  end
end
