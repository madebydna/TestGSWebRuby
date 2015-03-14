require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../pages/school_profile_overview_page'

shared_context 'with Alameda High School' do
  let!(:school) { FactoryGirl.create(:alameda_high_school) }
end

shared_context 'with an inactive school' do
  let!(:school) { FactoryGirl.create(:alameda_high_school, active: false) }
end

shared_context 'with a demo school' do
  let!(:school) { FactoryGirl.create(:demo_school, name: 'A demo school') }
end

shared_example 'should be on the correct page' do
  expect(subject).to be_displayed
end

shared_example 'should have element' do |element|
  instance_eval("expect(subject).to have_#{element}")
end

def expect_it_to_have_element(element)
  proc = Proc.new do
    it "should have the #{element} element" do
      instance_eval("expect(subject).to have_#{element}")
    end
  end
  instance_exec(&proc)
end


describe 'School Profile Overview Page' do
  include_context 'Visit School Profile Overview'

  after do
    clean_dbs :gs_schooldb
    clean_models School
  end

  with_shared_context 'Given basic school profile page' do
    with_shared_context 'with Alameda High School' do
      include_example 'should be on the correct page'
      expect_it_to_have_element(:profile_navigation)
    end

    with_shared_context 'with an inactive school' do
      it 'should not be on the profile page' do
        pending 'TODO: Do not allow profile page to handle inactive school'
        fail
      end
      # include_example 'should be on the correct page'
    end

    with_shared_context 'with a demo school' do
      include_example 'should be on the correct page'
      expect_it_to_have_element(:profile_navigation)
    end
  end

end

