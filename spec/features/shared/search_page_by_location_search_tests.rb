require 'spec_helper'
require_relative '../search/search_spec_helper'
require_relative '../shared/shared_examples_for_pages_with_assigned_schools'

# shared_examples_for '(features shared across all search pages)' do
shared_examples_for 'By Location Search' do
  include SearchSpecHelper
  let(:by_location_search_args) { ['100 North Dupont Road', 'Wilmington', 19807, 'DE', 39.752831, -75.588326] }
  standard_setup = Proc.new { set_up_by_location_search(*by_location_search_args) }

  #  assigned schools has a dependency to making an ajax request to java
  #  until we can implement tagging to only run this test on environments that can support this
  #  I'm stubbing this describe block
  #  ()the test is only not finished yet)

  # describe 'Assigned Schools' do
  #   it_should_behave_like 'a page with assigned schools among search results' do
  #     let(:search_results_container) { page.find(:css, '.js-searchResultsContainer') }
  #     before { allow_any_instance_of(SchoolSearchResult).to receive(:distance).and_return(0.00) }
  #     before &standard_setup
  #   end
  # end
end
