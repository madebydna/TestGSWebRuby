require 'spec_helper'
require 'features/contexts/nearby_cities_contexts'
require 'features/examples/nearby_cities_examples'
require 'features/contexts/search_contexts'
require 'features/examples/search_examples'
require 'features/examples/footer_examples'

describe 'Search Page' do
  describe 'City Browse' do
    describe 'search logic' do
      with_shared_context 'Visit dover delaware city browse' do
        with_shared_context 'when looking at school search results' do
          include_example 'should contain the expected text', *['Dover, DE']
        end

        describe 'breadcrumbs' do
          it { is_expected.to have_breadcrumbs }
          its('first_breadcrumb.title') { is_expected.to have_text('Delaware') }
          its('first_breadcrumb') { is_expected.to have_link('Delaware', href: "/delaware/") }
          its('second_breadcrumb.title') { is_expected.to have_text('Dover') }
          its('second_breadcrumb') { is_expected.to have_link('Dover', href: "/delaware/dover/") }
        end
      end
    end
  end

  describe 'By Location' do
    describe 'page specific elements' do
      include_context 'Visit By Location Search in Delaware'
      with_shared_context 'Sorting toolbar' do
        describe_mobile_and_desktop do
          include_example 'should contain distance sort select option'
        end
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
        with_shared_context 'when looking at school search results' do
          include_example 'should contain the expected text', *['Magnolia']
        end
      end
    end
  end

  #test that will get run on all search types
  {
    # city_browse:        Proc.new { include_context 'Visit youngstown ohio city browse' },
    # cant seem to get this working for compare. I think its not getting enough data.
    district_browse:    Proc.new { include_context 'Visit Appoquinimink  School District district browse' },
    by_name_search:     Proc.new { include_context 'Visit By Name Search dover elementary' },
    by_location_search: Proc.new { include_context 'Visit By Location Search in Delaware' }
  }.each_pair do | search_type, visit_page |
    describe "#{search_type}" do
      describe 'basic search page' do
        instance_exec &visit_page

        with_shared_context 'Search Page Search Bar' do
          include_example 'should have the typeahead css class in search bar'
          include_example 'should have a button to submit the search'
          include_examples 'should have Change Location link in search bar'
        end

        include_example 'should have list view link for search results'
        include_example 'should have map view link for search results'

        include_examples 'should have a footer'
        describe 'Comparing Schools', js: true do
          with_shared_context 'Select Schools and Go to compare' do
            include_example 'should be on compare page'
          end
        end
      end

      unless search_type == :by_name_search
        with_shared_context 'Nearby Cities in search bar' do
          instance_exec &visit_page
          include_example 'should have links to nearby cities'
        end
      end
    end
  end

end
