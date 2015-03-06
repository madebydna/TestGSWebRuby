require 'spec_helper'
require_relative '../examples/footer_examples'

describe 'Home Page' do
  before { visit home_path }
  subject { page }

  include_examples 'should have a footer'

end