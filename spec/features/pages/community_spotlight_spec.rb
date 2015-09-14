require 'spec_helper'
require 'features/selectors/community_spotlight_page'
require 'features/contexts/community_spotlight_contexts'
require 'features/examples/url_examples'
require 'features/examples/community_spotlight_examples'

describe 'community spotlight page', js: true do

  # TODO
  # - General page stuff:
  # -- Should have summary section and article section. How to mock i18n?
  # - Table interaction:
  # -- data is updated and schools are in correct order

  [
    {
      default_params: {},
      query_params: {},
      expected_query_params: {
        'sortBy' => 'a_through_g',
        'sortBreakdown' => 'hispanic',
        'sortAscOrDesc' => 'desc',
      },
      expected_subgroup_selection: 'Hispanic',
      expected_datatype_selection: 'Eligible for 4-Yr College',
      expected_highlight_column: 1,
    },
    {
      default_params: {}, # Use base defaults defined in community_spotlight_contexts
      query_params: {
        sortBreakdown: 'asian', sortBy: 'graduation_rate', sortAscOrDesc: 'asc'
      },
      expected_query_params: {
        sortBreakdown: 'asian', sortBy: 'graduation_rate', sortAscOrDesc: 'asc'
      },
      expected_subgroup_selection: 'Asian',
      expected_datatype_selection: 'Graduation Rate',
      expected_highlight_column: 2,
    },
  ].each do |opts|
    include_example 'community spotlight assertions', opts
  end
end
