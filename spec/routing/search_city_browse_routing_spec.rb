require 'spec_helper'

describe 'search district browse routing' do

  def request
    return double().as_null_object
  end

  before do
    # By default, the request used for the route will have domain of 'example.org', which will cause
    # RegularSubdomain constraint to not match
    allow_any_instance_of(ActionDispatch::Request).to receive(:subdomain).and_return('www')

    default_url_options[:host] = 'greatschools.org'
  end

  let(:state) { 'michigan' }

  it 'should route a multi-word district' do
    expect( get "/#{state}/michigan-city/schools/" ).to route_to(
      controller: 'search',
      action: 'city_browse',
      state: state,
      city: 'michigan-city'
    )
  end

  it 'should route a district with a period in it' do
    expect( get "/#{state}/st.-louis/schools/" ).to route_to(
      controller: 'search',
      action: 'city_browse',
      state: state,
      city: 'st.-louis'
    )
  end

  it 'should route a district with a number in it' do
    expect( get "/#{state}/city12/schools/" ).to route_to(
      controller: 'search',
      action: 'city_browse',
      state: state,
      city: 'city12'
    )
  end

  it 'should route a district beginning with a number in it' do
    expect( get "/#{state}/12th-city/schools/" ).to route_to(
      controller: 'search',
      action: 'city_browse',
      state: state,
      city: '12th-city'
    )
  end

  it 'should route a district with a # in it' do
    # %23 is the encoded value of #
    expect( get "/#{state}/city%2312/schools/" ).to route_to(
      controller: 'search',
      action: 'city_browse',
      state: state,
      city: 'city#12'
    )
  end
end
