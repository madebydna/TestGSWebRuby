require 'spec_helper'
require 'features/examples/page_examples'
require_relative '../examples/osp_examples'
require_relative '../examples/footer_examples'
require_relative '../../../spec/features/contexts/osp_contexts'

describe 'OSP Basic Page' do
  with_shared_context 'visit OSP page' do

    describe_mobile_and_desktop do
      it 'should have nav bar with school name' do
        subject.find('.rs-osp_school_name', text: school.name)
      end

      it 'should have dashboard button' do
        subject.find_button('dashboard')
      end

      it 'should have a submit button' do
        subject.find_button('Submit')
      end
    end

    osp_forms = ['Basic Information', 'Academics', 'Extracurriculars & Culture', 'Facilities & Staff', 'Basic Information']

    describe_desktop do
      osp_forms.each do |form|
        it 'should have an h3 with text ' + form do
          subject.find('h3', text: form)
        end
      end
    end

    describe_mobile do
      osp_forms.each do |form|
        it 'should have dropdown with text ' + form do
          click_button 'Basic Information'
          subject.find('.js-button-link', text: form)
        end
      end
    end
  end

  with_shared_context 'with a basic set of osp questions in db' do
    with_shared_context 'visit OSP page' do
      with_shared_context 'click a value in a conditional multi select group and then clicking none', js: true do
        include_example 'the conditional multi select group of questions should be disabled'

        with_shared_context 'submit the osp form' do
          include_example 'the conditional multi select group of questions should be disabled'
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
