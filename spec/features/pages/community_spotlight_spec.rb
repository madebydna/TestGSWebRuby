require 'spec_helper'
require 'features/selectors/community_spotlight_page'
require 'features/contexts/community_spotlight_contexts'
require 'features/examples/url_examples'
require 'features/examples/community_spotlight_examples'

describe 'community spotlight page', js: true do

  # Tests
  # = When visited with no query params, it should change the page to the default
  # - When visited with query params, it should update the dropdowns, highlight,
  #   sort preference, etc.
  # - General page stuff:
  # -- Should have summary section and article section. How to mock i18n?
  # - Table interaction:
  # -- change dropdown
  # -- change sort type
  # -- sort by data type
  # -- change URL

  # Mocking
  # - Solr results
  # - Schools
  # - School cache
  # - i18n stuff
  # -- Should get the translations by default, could just test a few things like
  #    I changed the title and it changed on the page.
  # - Page elements with SitePrism
  #
  # Expose the shouldRedraw JS variable and have capybara loop until it's true
  # before clicking anything
  #
  # Just have .js-drawTable in selectors and use their parents to decide if in
  # order to click that element it needs to open a dropdown

  with_shared_context 'visit community spotlight with collection, schools, and data' do
    it 'should have the default query string' do
      {
        'sortBy' => 'a_through_g',
        'sortBreakdown' => 'hispanic',
        'sortAscOrDesc' => 'desc',
      }.each do |key, value|
        expect_query_param(key, value)
      end
    end
    include_example 'should highlight column', 1
    with_shared_context 'click .js-drawTable element with', 'data-sort-by', 'graduation_rate' do
      include_example 'should have query parameter', 'sortBy', 'graduation_rate'
      include_example 'should highlight column', 2
    end
    with_shared_context 'click .js-drawTable element with', 'data-sort-asc-or-desc', 'asc' do
      include_example 'should have query parameter', 'sortAscOrDesc', 'asc'
    end
  end
end
