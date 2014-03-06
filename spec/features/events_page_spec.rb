require 'spec_helper'

describe 'Events Page' do
  let(:events_page_url) { 'http://localhost:3000/michigan/detroit/events' }
  before(:each) do
    if CollectionMapping.where(city: 'detroit', state: 'mi', active: 1).empty?
      cc = CollectionMapping.new(city: 'detroit', state: 'mi')
      cc.collection_id = 1
      cc.active = 1
      cc.save!
    end
  end

  after(:each) do
    CollectionMapping.last.destroy
  end

  it 'exists' do
    visit events_page_url
    expect(page).to have_text 'All events'
  end

  it 'shows breadcrumbs' do
    visit events_page_url
  end

  describe 'search bar' do
    it 'exists' do
      visit events_page_url
      expect(page).to have_content 'Find a school in detroit'
    end

    it 'searches' do
      visit events_page_url
      within('searchBySchoolNameForm') do
        fill_in 'q', with: 'elementary school'
        find('#js-submit').click
      end

      expect(current_path).to eq('search/search.page')
    end
  end
end
