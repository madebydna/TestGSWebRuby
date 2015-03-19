require 'spec_helper'

shared_context 'Largest cities on state home' do |index|
  index ||= 1
  subject { page.find(:css, ".state_bg_#{index}") }
end

shared_context 'when visiting /washington-dc' do
  before { visit state_path('washington-dc') }
end