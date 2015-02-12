require 'spec_helper'

shared_example 'should have links to nearby cities' do
  expect(subject).to have_css('.js-nearbyCity')
end
