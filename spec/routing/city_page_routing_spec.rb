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
    {
        'one-word state' => 'minnesota',
        'two-word state' => 'new-jersey'
    }.each do |state_description, state|
      describe state_description do
        {
            'one-word city' => 'minneapolis',
            'two-word city' => 'maple-grove',
            'city with a period in it' => 'st.-paul',
            'city with a # in it' => 'st.-%23aul',
            'city starting with a number' => '12th-city'
        }.each do |city_description, city|
          it "should route a #{city_description}" do
            expect( get "/#{state}/#{city}" ).to route_to('cities#show', state: state, city: city.sub('%23', '#'))
          end
        end
      end
    end
  end
end