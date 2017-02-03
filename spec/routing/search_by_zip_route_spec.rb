require 'spec_helper'

describe 'search by zip routing' do
  it 'should route /search/nearbySearch.page' do
    expect( get '/search/nearbySearch.page' ).to route_to('search#by_zip')
  end
end
