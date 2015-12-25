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
        describe city_description do
          {
              'normal district' => 'Alameda-School-District',
              'district with a period in it' => 'st.-paul-public-school-district',
              'district with a number in it' => 'district-12',
              'district beginning with a number' => '12th-district',
              'district with a # in it' => 'district-%2312'
          }.each do |district_description, district|
            it "should route a #{district_description}" do
              expect( get "/#{state}/#{city}/#{district}/schools/" ).to route_to('search#district_browse', state: state, city: city.sub('%23', '#'), district_name: district.sub('%23', '#'))
            end
          end
        end
      end
    end
  end
end
