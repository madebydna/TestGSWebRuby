require 'spec_helper'
require_relative '../contexts/school_profile_contexts'
require_relative '../examples/page_examples'
require_relative '../pages/school_profile_quality_page'



def expect_it_to_have_element(element)
  proc = Proc.new do
    it "should have the #{element} element" do
      instance_eval("expect(subject).to have_#{element}")
    end
  end
  instance_exec(&proc)
end


describe 'School Profile Quality Page' do

  before do
    pending 'AT-1165 new header set as default for now.'
    FactoryGirl.create(:page, name: 'Quality')
  end

  include_context 'Visit School Profile Quality'
  with_shared_context 'with Cristo Rey New York High School' do
    include_example 'should be on the correct page'
    expect_it_to_have_element(:profile_navigation)
  end

  after do
    clean_dbs :gs_schooldb, :ny
    clean_dbs :profile_config
    clean_models School
  end



end

