require 'spec_helper'
require_relative '../contexts/footer_contexts'
require 'features/selectors/state_home_page'


#Footer Shared Examples
shared_examples_for 'should have a footer' do
  include_example 'should have the .home-footer element'
  with_shared_context 'Footer' do
    include_example 'should have a language translation plugin'
    include_example 'should have an about great schools section'
  end
end

shared_example 'should have the .home-footer element' do
  expect(subject).to have_css('.home-footer')
end

shared_example 'should have a language translation plugin' do
  expect(subject).to have_css('#google_translate_element')
end

shared_example 'should have an about great schools section' do
  expect(subject).to have_content('About GreatSchools')
end


=begin
Will need to require the selector file to have this example work
Todo: need to make the selectors shared across pages
=end

shared_example 'should have state footer' do
  expect(subject).to have_state_footer
end
