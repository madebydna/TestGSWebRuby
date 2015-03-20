require 'spec_helper'
require_relative '../examples/osp_examples'
require_relative '../examples/footer_examples'
require_relative '../../../spec/features/contexts/osp_contexts'

shared_context 'visit OSP page' do
  include_context 'signed in approved osp user for school', :ca, 1
  let(:school) { FactoryGirl.create(:school, id: 1) }
  before do
    visit admin_osp_page_path(page:1,schoolId:school.id, state:school.state)
    # save_and_open_page
  end
  after do
    clean_models School
  end
  subject { page }
end

describe 'OSP Basic Page' do
  with_shared_context 'visit OSP page' do
    it 'should have an h1 with the school name' do
      subject.find('h1', text: school.name)
    end

    it 'should have dashboard button' do
      subject.find_button('dashboard')
    end

    it 'should have an h3 with text Basic Information' do
      subject.find('h3', text: 'Basic Information')
    end

    it 'should have an active class with Basic Information' do
      subject.find('.active', text: 'Basic Information')
    end

    it 'should have an h3 with text Academics' do
      subject.find('h3', text: 'Academics')
    end

    it 'should have an h3 with text Extracurriculars & Culture' do
      subject.find('h3', text: 'Extracurriculars & Culture')
    end

    it 'should have an h3 with text Facilities & Staff' do
      subject.find('h3', text: 'Facilities & Staff')
    end

  end

end