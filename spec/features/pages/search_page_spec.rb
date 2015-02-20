require 'spec_helper'
require_relative '../contexts/nearby_cities_contexts'
require_relative '../examples/nearby_cities_examples'
require_relative '../contexts/search_contexts'
require_relative '../examples/search_page_shared_examples'
require_relative '../examples/footer_shared_examples'

describe 'Search Page' do
  describe 'City Browse' do
    describe 'Features shared across search pages' do
      include_context 'Visit City Browse Search', *['oh', 'youngstown']
      subject { page }

      include_example  'should contain a search bar'

      with_shared_context 'Search Page Search Bar' do
        include_example 'should have the typeahead css class in search bar'
        include_example 'should have a button to submit the search'
        include_examples 'should have Change Location link in search bar'
      end

      include_examples 'should have a footer'
    end

    with_shared_context 'Nearby Cities in search bar' do
      include_context 'Visit City Browse Search', *['oh', 'youngstown']
      subject { page }
      include_example 'should have links to nearby cities'
    end
  end
end