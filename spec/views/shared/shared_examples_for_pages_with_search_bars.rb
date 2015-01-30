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
    expect(search_form_element.has_selector?('a', text: 'Change location')).to be_truthy
  end
end