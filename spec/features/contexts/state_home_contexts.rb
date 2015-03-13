require 'spec_helper'

shared_context 'Largest cities on state home' do |index|
  index ||= 1
  subject { page.find(:css, ".state_bg_#{index}") }
end
