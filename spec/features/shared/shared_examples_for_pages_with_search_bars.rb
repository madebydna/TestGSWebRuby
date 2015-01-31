require 'spec_helper'

shared_examples_for 'a page with a search page autocomplete search bar' do
  let(:search_form_element) { page.find(:css, '.js-schoolResultsSearchForm') }
  it 'should contain a search bar' do
    expect(page.body).to have_css('#js-schoolResultsSearch')
  end
  it 'should have the typeahead css class in search bar' do
    expect(search_form_element.has_selector?('.typeahead')).to be_truthy
  end
  it 'should have a button to submit the search' do
    expect(search_form_element.has_selector?('button', text: 'Search')).to be_truthy
  end
end

shared_examples_for 'a page with links to nearby cities' do
  it 'should have the js-nearbyCity class' do
    expect(page.body).to have_css('.js-nearbyCity')
  end
end

shared_examples_for 'a page with a change location button in the search bar' do
  let(:search_form_element) { page.find(:css, '.js-schoolResultsSearchForm') }

  it 'should have the change location anchor tag element' do
    expect(search_form_element.has_selector?('.rs-change_location')).to be_truthy
  end

  describe_mobile_and_desktop(self) do
    it 'should have a change location link that is visible' do
      expect(search_form_element).to have_selector('.rs-change_location', visible: true)
    end
    it 'should show list of states when the change location link is clicked' do
      expect(search_form_element).to have_selector('.rs-search_state_picker', visible: false)
      click_link 'Change location'
      expect(search_form_element).to have_selector('.rs-search_state_picker', visible: true)
    end
    context 'when the user clicks the link and changes the state' do
      it 'should change the text saying what state they\'re currently in' do
        text = search_form_element.find(:css, '.rs-current_location_text').text
        click_link 'Change location'
        first('.rs-search_state_picker > li > a').click
        text2 = search_form_element.find(:css, '.rs-current_location_text').text
        expect(text).not_to eq(text2)
      end
    end
  end
end