require 'spec_helper'
require 'features/examples/page_examples'
require_relative '../examples/osp_examples'
require_relative '../examples/footer_examples'
require_relative '../../../spec/features/contexts/osp_contexts'

describe 'OSP Basic Page' do
  with_shared_context 'visit OSP page' do
    it 'should have an h1 with the school name' do
      subject.find('h1', text: school.name)
    end

    # it 'should have dashboard button' do
    #   subject.find_button('dashboard')
    # end

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

    it 'should have a submit button' do
      subject.find_button('Submit')
    end
  end
  with_shared_context 'with a basic set of osp questions in db' do
    with_shared_context 'visit OSP page' do
      with_shared_context 'when clicking the none option on a question group' do
        context 'the group of questions', js: true do
          include_example 'should be disabled'
        end
      end
    end
  end

# describe 'should show active groups' do
#   question_group = FactoryGirl.create(:osp_question_groups)
#
#   it 'should show group title' do
#     subject.find('h3', text: question_group.heading)
#   end
#
#   puts question_group.image_path
#   subject.has_selector?("img[src$='osp/camera.png']")
#
# end
# end
end
