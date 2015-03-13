require 'spec_helper'

describe 'city page routing' do

  def request
    return double().as_null_object
  end

  before do
    # By default, the request used for the route will have domain of 'example.org', which will cause
    # RegularSubdomain constraint to not match
    allow_any_instance_of(ActionDispatch::Request).to receive(:subdomain).and_return('www')

    default_url_options[:host] = 'greatschools.org'
  end

  describe 'show' do
    it 'should route a one-word city' do
      expect( get '/minnesota/minneapolis/' ).to route_to('cities#show', state: 'minnesota', city: 'minneapolis')
    end

    it 'should route a two-word city' do
      expect( get '/minnesota/maple-grove/' ).to route_to('cities#show', state: 'minnesota', city: 'maple-grove')
    end

    it 'should route a city with a period in it' do
      expect( get '/minnesota/st.-paul/' ).to route_to('cities#show', state: 'minnesota', city: 'st.-paul')
    end
  end

end
