require 'spec_helper'
require 'features/selectors/community_spotlight_page'
require 'features/contexts/community_spotlight_contexts'
require 'features/examples/url_examples'
require 'features/examples/community_spotlight_examples'

describe 'community spotlight page', js: true do

  # Tests to do
  # - General page stuff:
  # -- Should have summary section and article section. How to mock i18n?
  # - Table interaction:
  # -- data is updated

  # Mocking
  # - i18n stuff if doing summary/article sections

  subgroup_select_desktop_selector = "[data-id='subgroup-select']"
  subgroup_select_mobile_selector = "[data-id='subgroup-select-mobile']"
  data_type_select_mobile_selector = "[data-id='data-type-select-mobile']"

  with_shared_context 'visit community spotlight with no query string' do
    context 'the page before interaction' do
      it 'should have the default query string' do
        {
          'sortBy' => 'a_through_g',
          'sortBreakdown' => 'hispanic',
          'sortAscOrDesc' => 'desc',
        }.each do |key, value|
          expect_query_param(key, value)
        end
      end
      describe_desktop do
        include_example 'should highlight column', 1
        include_example 'should have dropdown with selected value', subgroup_select_desktop_selector, 'Hispanic'
      end
      describe_mobile do
        include_example 'should have dropdown with selected value', subgroup_select_mobile_selector, 'Hispanic'
      end
    end
    context 'the page with interactions' do
      describe_desktop do
        with_shared_context 'click .js-drawTable element with', 'data-sort-by', 'graduation_rate' do
          include_example 'should have query parameter', 'sortBy', 'graduation_rate'
          include_example 'should highlight column', 2
        end
        with_shared_context 'click .js-drawTable element with', 'data-sort-breakdown', 'all_students' do
          include_example 'should have dropdown with selected value', subgroup_select_desktop_selector, 'All students'
        end
      end
      describe_mobile do
        with_shared_context 'click .js-drawTable element with', 'data-sort-by', 'graduation_rate' do
          include_example 'should have query parameter', 'sortBy', 'graduation_rate'
          include_example 'should have dropdown with selected value', data_type_select_mobile_selector, 'Graduation Rate'
        end
        with_shared_context 'click .js-drawTable element with', 'data-sort-breakdown', 'all_students' do
          include_example 'should have dropdown with selected value', subgroup_select_mobile_selector, 'All students'
        end
      end
      describe_mobile_and_desktop do
        with_shared_context 'click .js-drawTable element with', 'data-sort-asc-or-desc', 'asc' do
          include_example 'should have query parameter', 'sortAscOrDesc', 'asc'
        end
      end
    end
  end
  query_params = { sortBreakdown: 'asian', sortBy: 'graduation_rate', sortAscOrDesc: 'asc' }
  with_shared_context 'visit community spotlight with a query string', query_params do
    context 'the page before interactions' do
      it 'should have the default query string' do
        query_params.each do |key, value|
          expect_query_param(key, value)
        end
      end
      describe_desktop do
        include_example 'should highlight column', 2
        include_example 'should have dropdown with selected value', subgroup_select_desktop_selector, 'Asian'
      end
      describe_mobile do
        include_example 'should have dropdown with selected value', subgroup_select_mobile_selector, 'Asian'
      end
    end
  end
end
