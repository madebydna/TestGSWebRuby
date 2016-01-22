require 'spec_helper'
require 'features/contexts/school_profile_contexts'
require 'features/examples/page_examples'
require 'features/page_objects/school_profile_quality_page'
require 'features/examples/school_profile_header_examples'


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
    FactoryGirl.create(:page, name: 'Quality')
  end

  include_context 'Visit School Profile Quality'
  with_shared_context 'with Cristo Rey New York High School' do
    include_example 'should be on the correct page'
    it_behaves_like 'a page with school profile header'
  end

  after do
    clean_dbs :gs_schooldb, :ny
    clean_dbs :profile_config
    clean_models School
  end



end

