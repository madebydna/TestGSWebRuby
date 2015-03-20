require 'spec_helper'

describe 'district page routing' do

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
    it 'should route a multi-word district' do
      expect( get '/minnesota/st.-paul/minnesota-department-of-corrections/' ).to route_to(
        'districts#show',
        state: 'minnesota',
        city: 'st.-paul',
        district: 'minnesota-department-of-corrections'
      )
    end

    it 'should route a district with a period in it' do
      expect( get '/minnesota/st.-paul/st.-paul-public-school-district/' ).to route_to(
        'districts#show',
        state: 'minnesota',
        city: 'st.-paul',
        district: 'st.-paul-public-school-district'
      )
    end

    it 'should route a district with a number in it' do
      expect( get '/minnesota/st.-paul/district-12/' ).to route_to(
        'districts#show',
        state: 'minnesota',
        city: 'st.-paul',
        district: 'district-12'
      )
    end

    it 'should route a district beginning with a number in it' do
      expect( get '/minnesota/st.-paul/12th-district/' ).to route_to(
        'districts#show',
        state: 'minnesota',
        city: 'st.-paul',
        district: '12th-district'
      )
    end

    it 'should route a district with a # in it' do
      # %23 is the encoded value of #
      expect( get '/minnesota/st.-paul/district-%2312/' ).to route_to(
        'districts#show',
        state: 'minnesota',
        city: 'st.-paul',
        district: 'district-#12'
      )
    end
  end

end
