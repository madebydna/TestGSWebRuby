require 'spec_helper'
require_relative '../../../spec/features/search/search_spec_helper'
include SearchSpecHelper

shared_context 'Nearby Cities in search bar' do
  let(:cities) { %w(Anthony Christina Harrison Keith) }
  let(:nearby_cities) { set_up_nearby_cities(cities) }
  before { allow_any_instance_of(SearchNearbyCities).to receive(:search).and_return(nearby_cities) }
end