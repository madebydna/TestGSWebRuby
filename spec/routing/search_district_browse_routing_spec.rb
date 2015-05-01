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
  let(:city) { 'st-louis' }

  it 'should route a multi-word district' do
    expect( get "/#{state}/#{city}/michigan-public-schools/schools/" ).to route_to(
      controller: 'search',
      action: 'district_browse',
      state: state,
      city: city,
      district_name: 'michigan-public-schools'
    )
  end

  it 'should route a district with a period in it' do
    expect( get "/#{state}/#{city}/st.-louis-public-schools/schools/" ).to route_to(
      controller: 'search',
      action: 'district_browse',
      state: state,
      city: city,
      district_name: 'st.-louis-public-schools'
    )
  end

  it 'should route a district with a number in it' do
    expect( get "/#{state}/#{city}/district12/schools/" ).to route_to(
      controller: 'search',
      action: 'district_browse',
      state: state,
      city: city,
      district_name: 'district12'
    )
  end

  it 'should route a district beginning with a number in it' do
    expect( get "/#{state}/#{city}/12th-district/schools/" ).to route_to(
      controller: 'search',
      action: 'district_browse',
      state: state,
      city: city,
      district_name: '12th-district'
    )
  end

  it 'should route a district with a # in it' do
    # %23 is the encoded value of #
    expect( get "/#{state}/#{city}/district%2312/schools/" ).to route_to(
      controller: 'search',
      action: 'district_browse',
      state: state,
      city: city,
      district_name: 'district#12'
    )
  end

  it 'should route a district within a city with a period in it' do
    city = 'st.-louis'
    expect( get "/#{state}/#{city}/district/schools/" ).to route_to(
      controller: 'search',
      action: 'district_browse',
      state: state,
      city: city,
      district_name: 'district'
    )
  end

end
