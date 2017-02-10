require 'spec_helper'

def expect_redirect_to(path)
  expect(response.status).to eq(301)
  expect(response.headers['Location']).to eq("http://www.example.com#{path}")
end

describe 'All cities in state list pagination links' do
  it 'redirects to the main page' do
    get '/schools/cities/New_Jersey/NJ/A/'
    expect_redirect_to '/schools/cities/New_Jersey/NJ/'
  end
end

describe 'All districts in state list pagination links' do
  it 'redirects to the main page' do
    get '/schools/districts/New_Jersey/NJ/A/'
    expect_redirect_to '/schools/districts/New_Jersey/NJ/'
  end
end