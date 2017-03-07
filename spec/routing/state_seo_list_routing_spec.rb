require 'spec_helper'

describe 'All schools/cities/districts in state page routing' do
  [
      %w(Washington_DC DC),
      %w(anything anything-else)
  ].each do |(state_name, state_abbr)|
    it "handles /schools/#{state_name}/#{state_abbr}/" do
      expect( get "/schools/#{state_name}/#{state_abbr}/" ).to route_to('schools_list#show', state_name: state_name, state_abbr: state_abbr)
    end

    it "handles /schools/cities/#{state_name}/#{state_abbr}/" do
      expect( get "/schools/cities/#{state_name}/#{state_abbr}/" ).to route_to('cities_list#show', state_name: state_name, state_abbr: state_abbr)
    end

    it "handles /schools/districts/#{state_name}/#{state_abbr}/" do
      expect( get "/schools/districts/#{state_name}/#{state_abbr}/" ).to route_to('districts_list#show', state_name: state_name, state_abbr: state_abbr)
    end
  end
end