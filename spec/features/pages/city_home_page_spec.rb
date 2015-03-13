require 'spec_helper'
require_relative '../examples/page_examples'
require_relative '../contexts/state_home_contexts'

describe 'City Home Page' do
  before do
    create(:city, state: 'mn', name: 'St. Paul')
    visit city_path('minnesota', 'st.-paul')
  end
  after { clean_dbs :us_geo }
  subject { page }

  # PT-1347 This is a test in itself because this URL used to be unreachable
  include_example 'should have url path', '/minnesota/st.-paul/'

end
