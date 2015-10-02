require 'spec_helper'
require 'features/examples/community_spotlight_examples'
require 'features/contexts/collection_configs'

describe 'community spotlight page', js: true do

  # TODO
  # - General page stuff:
  # -- Should have summary section and article section. How to mock i18n?
  # - Table interaction:
  # -- data is updated and schools are in correct order

  [
    bay_area_collection_config,
  ].each do |collection_config|
    include_example 'community spotlight assertions', collection_config
  end
end
