require 'spec_helper'

describe 'create review routing' do

  def request
    return double.as_null_object
  end

  before do
    # By default, the request used for the route will have domain of 'example.org', which will cause
    # RegularSubdomain constraint to not match
    allow_any_instance_of(ActionDispatch::Request).to receive(:subdomain).and_return('www')

    default_url_options[:host] = 'greatschools.org'
  end

  it 'should route correctly' do
    expect( post create_reviews_path()).to route_to(action: 'create', controller: 'reviews')
  end
end
