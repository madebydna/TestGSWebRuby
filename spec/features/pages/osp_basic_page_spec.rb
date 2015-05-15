require 'spec_helper'
require 'features/examples/page_examples'
require 'features/contexts/queue_daemon_contexts'
require 'features/contexts/compare_schools_contexts'
require_relative '../examples/osp_examples'
require_relative '../examples/footer_examples'
require_relative '../../../spec/features/contexts/osp_contexts'
require 'features/examples/osp_examples'
require 'features/examples/footer_examples'
require 'features/contexts/osp_contexts'

describe 'OSP Basic Page' do
  with_shared_context 'visit OSP superuser page' do
    describe_mobile_and_desktop do
      include_example 'should have switch schools link'
    end
  end

  with_shared_context 'visit OSP page' do

    describe_mobile_and_desktop do

      include_example 'should have nav bar with school name'
      include_example 'should have a submit button'
      include_example 'should have basic school information'
      include_example 'should have school address'

    end

    osp_forms = ['Basic Information', 'Academics', 'Extracurriculars & Culture', 'Facilities & Staff']

    describe_desktop do
      osp_forms.each do |form|
        with_shared_context 'Within the h3 with text', form do
          include_example 'should contain the expected text', form
        end
      end

      include_example 'should have go to school profile button'
    end

    describe_mobile do
      osp_forms.each do |form|
        with_shared_context 'click OSP mobile nav', form do
          include_example 'should contain the expected text', form
        end
      end

      include_example 'should have go to school profile link'
    end
  end

  with_shared_context 'with a basic set of osp questions in db' do
    with_shared_context 'visit OSP page' do

      with_shared_context 'click a value in a conditional multi select group and then click none', js: true do
        include_example 'the conditional multi select group of questions should be disabled'

        with_shared_context 'submit the osp form' do
          include_example 'the conditional multi select group of questions should be disabled'

          with_shared_context 'the OspFormResponse objects\' responses in the db' do
            include_example 'should only contain the following values in the form response', ['none', 'neither']
          end
        end
      end

      with_shared_context 'click Before Care and Canoe button options', js: true do
        with_shared_context 'submit the osp form' do
          include_example 'Before Care and Canoe buttons should be active'
        end

        #testing that nav auto-submits form
        with_shared_context 'click osp nav link element with text:', 'Academics' do
          include_example 'Before Care and Canoe buttons should be active'
        end

        describe_mobile do
          with_shared_context 'click OSP mobile nav' do
            with_shared_context 'click osp nav link element with text:', 'Academics' do
              include_example 'Before Care and Canoe buttons should be active'
            end
          end
        end
      end

      describe_mobile_and_desktop do
        with_shared_context 'click No Dress code and Dress code radio buttons' do
          with_shared_context 'within osp form' do
            include_example 'should only have one active button'
          end
          with_shared_context 'submit the osp form' do
            with_shared_context 'within osp form' do
              include_example 'should only have one active button'
            end
          end
        end

        with_shared_context 'enter following text into text field with name', 'uuddlrlrbas', :boardgames do
          with_shared_context 'submit the osp form' do
            with_shared_context 'within input field', :boardgames do
              include_example 'should eql the expected value', 'uuddlrlrbas'
            end
          end
        end

        with_shared_context 'enter information into medium text field' do
          with_shared_context 'submit the osp form' do
            with_shared_context 'within textarea field', :puzzlegames do
              include_example 'should eql the expected value', 'upupdowndownleftrightleftrightBAstart'
            end
          end
        end

        with_shared_context 'enter information into large text field' do
          with_shared_context 'submit the osp form' do
            with_shared_context 'within textarea field', :videogames do
              include_example 'should eql the expected value', 'upupdowndownleftrightleftrightBAstart'
            end
          end
        end

        with_shared_context 'enter following text into text field with name', 'you awesome', :award do
          with_shared_context 'submit the osp form' do
            with_shared_context 'within input field', :award do
              include_example 'should eql the expected value', 'you awesome'
            end
          end

          #conditional select box that should only be active if there is a value in text field
          with_shared_context 'within select box', :award_year do
            include_example 'should not be disabled'
          end

          with_shared_context 'selecting the following option in select box with name', '2015', :award_year do
            with_shared_context 'submit the osp form' do
              with_shared_context 'within select box', :award_year do
                include_example 'should eql the expected value', '2015'
              end
            end
          end
        end

        with_shared_context 'within select box', :award_year do
          include_example 'should be disabled'
        end
      end
    end
  end

  with_shared_context 'with a basic set of parsley validated osp questions in db' do
    with_shared_context 'visit OSP page' do

      with_shared_context 'enter following text into text field with name', 'uuddlrlrbas', :boardgames, js: true do
        with_shared_context 'within textarea field', :boardgames do
          include_example 'should not submit value in text field'
        end
      end

      with_shared_context 'enter information into medium text field', js: true do
        with_shared_context 'within textarea field', :puzzlegames do
          include_example 'should not submit value in text field'
        end
      end

      with_shared_context 'enter information into large text field', js: true do
        with_shared_context 'within textarea field', :videogames do
          include_example 'should not submit value in text field'
        end
      end

      with_shared_context 'enter video url information into medium text field', js: true do
        with_shared_context 'within textarea field', :video_urls do
          include_example 'should not submit value in text field'
        end
      end
      with_shared_context 'enter video url information into medium text field', js: true do
        with_shared_context 'within textarea field', :normal_text_field do
          include_example 'should not submit value in text field'
        end
      end
    end
  end

  with_shared_context 'Basic High School' do
    with_shared_context 'Visit Compare Page', js: true do
      with_shared_context 'the compare page value of', 'Before care' do
        include_example 'should eql the expected text', ''
      end
    end
  end

  with_shared_context 'with a basic set of osp questions in db' do
    with_shared_context 'visit OSP page' do
      with_shared_context 'click Before Care and Canoe button options', js: true do
        with_shared_context 'submit the osp form' do
          include_context 'then run the queue daemon', :ca
          with_shared_context 'Visit Compare Page' do
            with_shared_context 'the compare page value of', 'Before care' do
              include_example 'should contain the expected text', 'Yes'
            end
          end
        end
      end
    end
  end

end
