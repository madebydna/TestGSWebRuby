require 'spec_helper'
require_relative '../examples/page_examples'
require_relative '../contexts/state_home_contexts'

describe 'State Home Page' do
  before do
    create(:city, state: 'mn', name: 'St. Paul')
    visit state_path('minnesota')
  end
  after { clean_dbs :us_geo }
  subject { page }

  with_shared_context 'Largest cities on state home' do
    include_example 'should have a link with', text: 'ST. PAUL', href: '/minnesota/st.-paul/'
  end

end
