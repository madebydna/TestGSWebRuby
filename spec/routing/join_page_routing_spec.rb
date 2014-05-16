require 'spec_helper'

describe 'join / login page routing' do

  def request
    return double().as_null_object
  end

  before do
    # By default, the request used for the route will have domain of 'example.org', which will cause
    # RegularSubdomain constraint to not match
    allow_any_instance_of(ActionDispatch::Request).to receive(:subdomain).and_return('www')

    default_url_options[:host] = 'greatschools.org'
  end

  describe 'join' do
    it 'should route /join/' do
      expect( get '/join/' ).to route_to('signin#new_join')
    end
  end

  describe 'login' do
    it 'should route /gsr/login/' do
      expect( get '/gsr/login/' ).to route_to('signin#new')
    end
  end

end
