require 'spec_helper'
require 'features/examples/page_examples'
require 'features/contexts/queue_daemon_contexts'
require 'features/contexts/compare_schools_contexts'
require 'features/examples/osp_examples'
require 'features/contexts/osp_contexts'
require 'features/examples/osp_examples'
require 'features/examples/footer_examples'

describe 'OSP Basic Page' do
  with_shared_context 'visit OSP superuser page' do
    describe_mobile_and_desktop do
      include_example 'should have switch schools link'
    end
  end

  with_shared_context 'visit OSP page' do

    describe_mobile_and_desktop do

      include_example 'should have nav bar with school name'
      include_example 'should have basic school information'
      include_example 'should have school address'
      include_example 'should have need help link'
      describe 'footer' do
        subject { OspPage.new }
        include_examples 'should have a footer'
      end
    end

    osp_forms = ['Basic Information', 'Academics', 'Extracurriculars & Culture']

    describe_desktop do
      osp_forms.each do |form|
        with_shared_context 'Within the h3 with text', form do
          include_example 'should contain the expected text', form
        end
      end

      include_example 'should have a save edits button', 2
      include_example 'should have go to school profile button'
      include_example 'should have begin writing here link'
    end

    describe_mobile do
      osp_forms.each do |form|
        with_shared_context 'click OSP mobile nav', form do
          include_example 'should contain the expected text', form
        end
      end

      include_example 'should have a save edits button', 1
      include_example 'should have save edits link'
      include_example 'should have go to school profile link'
      include_example 'should have write administratro reviews link'
    end
  end

  with_shared_context 'signed in approved osp user for school', 'ca', 1 do
    before { skip }
    with_shared_context 'visit OSP page with inactive school', js: true do
        include_example 'should have element with text', '.flash_notice', 'Exceptional Death Eaters Academy may no longer exist. If you feel this is incorrect, please contact us.'
        include_example 'should have link text on page', 'contact us'
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
          describe 'footer' do
            subject { OspPage.new }
            include_examples 'should have a footer'
          end
          include_example 'Before Care and Canoe buttons should be active'
        end

        with_shared_context 'click osp nav link element with text:', 'Extracurriculars' do
          describe 'footer' do
            subject { OspPage.new }
            include_examples 'should have a footer'
          end
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

        # include_example 'should have need help link'

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

       with_shared_context 'find input field with name', :date_picker do
         include_example 'should display calendar picker'
       end

        with_shared_context 'enter following text into text field with name', '$1000', :tuition_low do
          with_shared_context 'submit the osp form' do
            with_shared_context 'within input field', :tuition_low do
              include_example 'should eql the expected value', '$1000'
            end
          end

          #conditional select box that should only be active if there is a value in text field
          with_shared_context 'within select box', :tuition_year do
            include_example 'should not be disabled'
          end


          with_shared_context 'selecting the following option in select box with name', '2014-2015', :tuition_year do
            with_shared_context 'submit the osp form' do
              with_shared_context 'within select box', :tuition_year do
                include_example 'should eql the expected value', '2014-2015'
              end
            end
          end
        end

        with_shared_context 'within select box', :tuition_year do
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
      with_shared_context 'enter following text into text field with name', 'uuddlrlrbas', :school_phone, js: true do
        with_shared_context 'within textarea field', :school_phone do
          include_example 'should not submit value in text field'
        end
      end
      with_shared_context 'enter following text into text field with name', 'uuddlrlrbas', :school_fax, js: true do
        with_shared_context 'within textarea field', :school_fax do
          include_example 'should not submit value in text field'
        end
      end
    end
  end

  with_shared_context 'with a basic set of osp questions in db' do
    with_shared_context 'with oddly formatted data in school cache for school', 'CA', 1 do
      with_shared_context 'visit OSP page', js: true do
        with_shared_context 'within button(s) with the text(s)', 'Before Care' do
          include_example 'should contain the active class'
        end
        with_shared_context 'within button(s) with the text(s)', 'Unicycle!!!' do
          include_example 'should be disabled'
        end
        with_shared_context 'within button(s) with the text(s)', 'No dress code' do
          include_example 'should contain the active class'
        end
      end
    end
  end

end
