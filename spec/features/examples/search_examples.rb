require 'spec_helper'
require 'features/contexts/search_contexts'

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

shared_example 'should have list view link for search results' do
  expect(subject).to have_search_results_list_view_link
end

shared_example 'should have map view link for search results' do
  expect(subject).to have_search_results_map_view_link
end

#Change Location Shared Examples
shared_examples_for 'should have Change Location link in search bar' do
  include_example 'should have the change location element'
end

shared_example 'should have the change location element' do
  expect(subject).to have_selector('select#change-location-desktop')
end

shared_example 'should be on compare page' do
  expect(current_path).to eq compare_schools_path.chop
end


#By Location examples
shared_example 'should contain distance sort select option' do
  subject.find('[data-id="search-page-sort"]').click
  expect(subject).to have_selector('[data-sort-type="distance"]')
end
