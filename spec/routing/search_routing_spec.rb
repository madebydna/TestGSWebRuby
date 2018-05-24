# frozen_string_literal: true

require 'spec_helper'

describe 'search routing' do
  def request
    return double.as_null_object
  end

  before do
    # By default, the request used for the route will have domain of 'example.org', which will cause
    # RegularSubdomain constraint to not match
    allow_any_instance_of(ActionDispatch::Request).to receive(:subdomain).and_return('www')

    default_url_options[:host] = 'greatschools.org'
  end

  describe "old search" do
    it "should route to search controller" do
      expect( get "/search/search.page" ).to route_to('search#search')
    end
  end

  describe "new search" do
    it "should route to new search controller" do
      expect( get "/search/search.page?newsearch" ).to route_to('new_search#search', newsearch: nil)
    end
  end

end