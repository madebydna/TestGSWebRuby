require 'spec_helper'
require 'features/contexts/nearby_cities_contexts'
require 'features/examples/nearby_cities_examples'
require 'features/contexts/search_contexts'
require 'features/examples/search_examples'
require 'features/examples/footer_examples'

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

    describe_mobile_and_desktop do
      describe 'Comparing Schools' do
        include_context 'Visit City Browse Search', *['oh', 'youngstown']
        with_shared_context 'Select Schools and Go to compare' do
          include_example 'should be on compare page'
        end
      end
    end
  end

  describe 'By Location' do
    describe_mobile_and_desktop do
      describe 'Comparing Schools' do
        include_context 'Visit By Location Search', *['100 North Dupont Road', 'Wilmington', 19807, 'DE', 39.752831, -75.588326]
        with_shared_context 'Select Schools and Go to compare' do
          include_example 'should be on compare page'
        end
      end
    end

    describe 'page specific elements' do
      include_context 'Visit By Location Search', *['100 North Dupont Road', 'Wilmington', 19807, 'DE', 39.752831, -75.588326]
      with_shared_context 'Sorting toolbar' do
        describe_desktop { include_example 'should contain distance sort button' }
        describe_mobile { include_example 'should contain distance sort select option'}
      end
    end
  end

  describe 'By Name' do
    describe 'search logic' do
      with_shared_context 'Visit by name search using parameters state=de and q=north' do
        context 'when looking at search results school names' do
          subject { page.all(:css, '.rs-schoolName') }
          include_example 'should contain the expected text', *['North']
        end
      end

      with_shared_context 'Visit by name search using parameters state=de and q=magnolia' do
        context 'when looking at search results school addresses' do
          subject { page.all(:css, '.rs-schoolAddress') }
          include_example 'should contain the expected text', *['Magnolia']
        end
      end
    end
  end

end