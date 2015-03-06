require 'spec_helper'
require 'features/search/search_spec_helper'
require 'features/examples/page_examples'
include SearchSpecHelper

#Visiting Search Pages
shared_context 'Visit City Browse Search' do |state_abbrev, city_name, query_string=nil|
  before do
    set_up_city_browse(state_abbrev,city_name,query_string)
  end
end

shared_context 'Visit By Location Search' do |address, city_name, zipcode, lat, lon, query_string=nil|
  before do
    set_up_by_location_search(address, city_name, zipcode, lat, lon, query_string)
  end
end

shared_context 'Visit By Name Search' do |search_term, state, query_string|
  before do
    set_up_by_name_search(search_term, state, query_string)
  end
end

shared_context 'Search Page Search Bar' do
  let(:search_form_element) { page.find(:css, '.js-schoolResultsSearchForm') }
end


#Compare Contexts
shared_context 'Select Schools and Go to compare' do
  include_context 'Click compare on school result number', 1
  include_context 'Click compare on school result number', 2
  include_context 'Click Compare Schools'
  include_context 'Set subject to current_path'
end

shared_context 'Click compare on school result number' do | result_number |
  before do
    school_result = page.all('.js-compareSchoolButton')[result_number - 1]
    school_result.click
    #Compare locks selecting other compare schools until the animation of the first one completes
    #Thus we may need to add a sleep to let the animation finish.
    # sleep 1
  end
end

shared_context 'Click Compare Schools' do
  before do
    # may need to add a sleep
    # sleep 1
    popup_button = page.all('.js-compareSchoolsPopupButton').first
    popup_button.click
    submit_button = page.all('.js-compareSchoolsSubmit').first
    submit_button.click
  end
end

shared_context 'Set subject to current_path' do
  subject { current_path }
end

shared_context 'Visit by name search using parameters state=de and q=north' do
  include_context 'Visit By Name Search', *['north', 'de']
end

shared_context 'Visit by name search using parameters state=de and q=magnolia' do
  include_context 'Visit By Name Search', *['magnolia', 'de']
end

shared_context 'Visit dover delaware city browse' do
  include_context 'Visit City Browse Search', *['de', 'dover']
end

shared_context 'Sorting toolbar' do
  subject { page.find(:css, '.js-sortingToolbar') }
end
