require 'spec_helper'

shared_context 'Footer' do
  subject { page.find(:css, '.home-footer') }
end