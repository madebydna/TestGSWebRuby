require 'spec_helper'

describe 'create review routing' do

  def request
    return double().as_null_object
  end

  def expect_route_to_be_correct_for_city(*args)
    if args.size == 1
      city_param = args.first
      city = args.first
    elsif args.size == 2
      city_param, city = args
    end
    expect( post school_reviews_path(nil, school_params.merge(city: city_param)) ).to route_to(action: 'create', controller: 'school_profile_reviews', state: 'south-carolina', city: city, schoolId: '1', school_name: 'Keith-School-Of-Excellence')
  end

  before do
    # By default, the request used for the route will have domain of 'example.org', which will cause
    # RegularSubdomain constraint to not match
    allow_any_instance_of(ActionDispatch::Request).to receive(:subdomain).and_return('www')

    default_url_options[:host] = 'greatschools.org'
  end

  let(:school_params) {
    {
      state_name: 'south carolina',
      id: 1,
      name: 'Keith School Of Excellence'
    }
  }

  it 'should route a school within a one-word city' do
    expect_route_to_be_correct_for_city('asheville')
  end

  it 'should route a school within a two-word city' do
    expect_route_to_be_correct_for_city('north_asheville')
  end

  it 'should route a school within a city with a period in it' do
    expect_route_to_be_correct_for_city('st._asheville')
  end

  it 'should route a school within a city with a # in it' do
    expect_route_to_be_correct_for_city('asheville%234', 'asheville#4')
  end

end