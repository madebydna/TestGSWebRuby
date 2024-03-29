require 'spec_helper'
require 'features/contexts/footer_contexts'
require 'features/page_objects/state_home_page'


#Footer Shared Examples
shared_examples_for 'should have a footer' do
  it { is_expected.to have_footer }
  it { is_expected.to_not have_selector('.js-shortFooter') }
  it { is_expected.to_not have_selector('.rs-state-footer') }
  it { is_expected.to_not have_selector('.home-footer') }
  it { is_expected.to_not have_selector('.rs-about-gs-footer') }
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
