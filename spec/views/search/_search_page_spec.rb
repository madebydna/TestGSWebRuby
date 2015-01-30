require 'spec_helper'
require_relative '../../features/search/search_spec_helper'
require_relative '../shared/shared_examples_for_pages_with_search_bars'


describe 'search/search_page.html.erb' do
  describe '(features shared across all search pages)' do
    include SearchSpecHelper
    {
      city_browse:        ['oh','youngstown'],
      district_browse:    ['de','Appoquinimink School District','Appoquinimink'],
      by_name_search:     ['dover elementary', 'DE'],
      by_location_search: ['100 North Dupont Road', 'Wilmington', 19807, 'DE', 39.752831, -75.588326],
    }.each_pair do | search_type, args |
      standard_setup = Proc.new { send("set_up_#{search_type}".to_sym, *args) }
      describe "#{search_type}" do
        describe 'search bar' do
          before &standard_setup
          it_should_behave_like 'a page with a search page autocomplete search bar'
          it_should_behave_like 'a page with a change location button in the search bar'
        end
        unless search_type == :by_name_search
          describe 'Nearby Cities' do
            let(:cities) { %w(Anthony Christina Harrison Keith) }
            let(:nearby_cities) { set_up_nearby_cities(cities) }
            before do
              send("set_up_#{search_type}".to_sym, *args) do
                allow_any_instance_of(SearchNearbyCities).to receive(:search).and_return(nearby_cities)
              end
            end
            it_should_behave_like 'a page with links to nearby cities'
          end
        end
      end
    end
  end
end
