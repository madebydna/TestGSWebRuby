require 'spec_helper'
require 'features/page_objects/district_boundaries_page'

describe 'User visits district boundaries page' do
  before { visit district_boundary_path }
  subject(:page_object) { DistrictBoundariesPage.new }
  it { is_expected.to have_top_nav }
end

