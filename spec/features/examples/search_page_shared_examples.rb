require 'spec_helper'
require_relative '../contexts/search_contexts'

#Search Bar Shared Examples
shared_example 'should contain a search bar' do
  expect(subject).to have_css('#js-schoolResultsSearch')
end

shared_example 'should have the typeahead css class in search bar' do
  expect(subject).to have_css('.typeahead')
end

shared_example 'should have a button to submit the search' do
  expect(subject.has_selector?('button', text: 'Search')).to be_truthy
end


#Change Location Shared Examples
shared_examples_for 'should have Change Location link in search bar' do

  include_example 'should have the change location anchor tag element'

  describe_mobile_and_desktop do
    include_example 'should have a change location link that is visible'
    include_example 'should show list of states when the change location link is clicked'

    context 'when the user clicks the link and changes the state' do
      include_example 'should change the text saying what state they\'re currently in'
    end
  end
end

shared_example 'should have the change location anchor tag element' do
  expect(subject).to have_css('.rs-change_location')
end

shared_example 'should have a change location link that is visible' do
  expect(subject).to have_selector('.rs-change_location', visible: true)
end

shared_example 'should show list of states when the change location link is clicked' do
  expect(subject).to have_selector('.rs-search_state_picker', visible: false)
  click_link 'Change location'
  expect(subject).to have_selector('.rs-search_state_picker', visible: true)
end

shared_example 'should change the text saying what state they\'re currently in' do
  text = subject.find(:css, '.rs-current_location_text').text
  click_link 'Change location'
  first('.rs-search_state_picker > li > a').click
  text2 = subject.find(:css, '.rs-current_location_text').text
  expect(text).not_to eq(text2)
end
