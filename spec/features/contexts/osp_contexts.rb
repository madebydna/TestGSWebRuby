require 'spec_helper'
require 'support/shared_contexts_for_signed_in_users'
require 'features/selectors/osp_page'

### Setting Up Signed in User ###

shared_context 'signed in approved osp user for school' do |state, school_id|
  before do
    factory_girl_options = {state: state, school_id: school_id}.delete_if {|_,v| v.nil?}
    user = FactoryGirl.create(:verified_user, :with_approved_esp_membership, factory_girl_options)
    log_in_user(user)
  end

  after do
    clean_models User, EspMembership
  end
end

### School Blocks ###

shared_context 'Basic High School' do
  let(:school) { FactoryGirl.create(:school, id: 1, level_code: 'h') }
  after { clean_models School }
end

### Navigation ###

shared_context 'visit OSP page' do
  include_context 'signed in approved osp user for school', :ca, 1
  include_context 'Basic High School'
  let(:osp_page) { OspPage.new }
  before do
    visit admin_osp_page_path(page: 1, schoolId: school.id, state: school.state)
  end
  subject { page }
end

shared_context 'click osp nav link element with text:' do |text|
  before do
    button = osp_page.osp_nav.nav_buttons(text: text).first
    button.click
  end
end

### DB Setup ###

shared_context 'with a basic set of osp questions in db' do
  let(:question_ids) do
    {
      before_after_care: 1,
      transportation:    2,
      dress_code:        3,
      boardgames:        4,
      puzzlegames:       5,
      videogames:        6
    }
  end
  let(:questions) do
    [
      {
        id: question_ids[:before_after_care],
        esp_response_key: :before_after_care,
        osp_question_group_id: nil,
        question_type: 'multi_select',
        config: { #will be turned into json, so needs to be string
          'answers' => {
            "Before Care" => "before",
            "After Care" => "after",
          }
        }.to_json
      },
      {
        id: question_ids[:tansportation],
        esp_response_key: :transportation,
        osp_question_group_id: nil,
        question_type: 'conditional_multi_select',
        config: { #will be turned into json, so needs to be string
          'answers' => {
            'Bus' => 'bus',
            'Canoe' => 'canoe',
            'Unicycle!!!' => 'unicycle'
          },
          'options' => {
            'text_label' => 'General'
          }
        }.to_json
      },
      {
        id: question_ids[:dress_code],
        esp_response_key: :dress_code,
        osp_question_group_id: nil,
        question_type: 'radio',
        config: { #will be turned into json, so needs to be string
          'answers' => {
            'Dress code' => 'dress_code',
            'Uniform' => 'uniform',
            'No dress code' => 'no_dress_code'
          }
        }.to_json
      },
      {
          id: question_ids[:boardgames],
          esp_response_key: :boardgames,
          osp_question_group_id: nil,
          question_type: 'input_field_sm'
      },
      {
          id: question_ids[:videogames],
          esp_response_key: :videogames,
          osp_question_group_id: nil,
          question_type: 'input_field_lg'

      },
      {
          id: question_ids[:puzzlegames],
          esp_response_key: :puzzlegames,
          osp_question_group_id: nil,
          question_type: 'input_field_md'

      }
    ]
  end

  include_context 'save osp question to db'
end

shared_context 'with a basic set of parsley validated osp questions in db' do
  let(:question_ids) do
    {
        boardgames:        1,
        puzzlegames:       2,
        videogames:        3
    }
  end
  let(:questions) do
    [
        {
            id: question_ids[:boardgames],
            esp_response_key: :boardgames,
            osp_question_group_id: nil,
            question_type: 'input_field_sm',
            config: {
                'validations' => {
                    'data-parsley-type' => 'email',
                    'data-parsley-trigger' => 'keyup'
                }
            }.to_json
        },
        {
            id: question_ids[:videogames],
            esp_response_key: :videogames,
            osp_question_group_id: nil,
            question_type: 'input_field_lg',
            config: {
                'validations' => {
                    'data-parsley-type' => 'email',
                    'data-parsley-trigger' => 'keyup'
                }
            }.to_json

        },
        {
            id: question_ids[:puzzlegames],
            esp_response_key: :puzzlegames,
            osp_question_group_id: nil,
            question_type: 'input_field_md',
            config: {
                'validations' => {
                    'data-parsley-type' => 'email',
                    'data-parsley-trigger' => 'keyup'
                }
            }.to_json

        }
    ]
  end

  include_context 'save osp question to db'
end

shared_context 'save osp question to db' do
  before do
    questions.each do |question|
      FactoryGirl.create(:osp_question, :with_osp_display_config, question)
    end
  end
  after { clean_models :gs_schooldb, OspQuestion, OspDisplayConfig }
end

### Clicking Buttons ###

shared_context 'click Before Care and Canoe button options' do
  let(:selected_answers) { ['Before Care', 'Canoe'] }
  include_context 'click several buttons'
end

shared_context 'click No Dress code and Dress code radio buttons' do
  let(:selected_answers) { ['No dress code', 'Dress code'] }
  include_context 'click several buttons'
end

shared_context 'click several buttons' do #Can be radio, multi-select, or conditional multi-select types
  before do
    answers = Regexp.new(selected_answers.join('|'))
    elements = osp_page.osp_form.buttons(text: answers)
    elements.each(&:click)
  end
end

shared_context 'click the none option on a conditional multi select question group' do
  before do
    trigger = osp_page.osp_form.conditionalMultiSelectTrigger.first
    trigger.click if trigger.present?
  end
  subject do
    osp_page.osp_form.conditionalMultiSelectTarget
  end
end

shared_context 'click a value in a conditional multi select group and then click none' do
  before do
    button = osp_page.osp_form.conditionalMultiSelectTarget.first
    button.click if button.present?
  end

  include_context 'click the none option on a conditional multi select question group'
end

### Open text / input fields ###

shared_context 'enter information into small text field' do
  before do
    form = osp_page.osp_form
    form.find("form input[type=text]").set "uuddlrlrbas"
  end
  end

shared_context 'enter information into medium text field' do
  before do
    form = osp_page.osp_form
    form.find("form textarea[name='#{question_ids[:puzzlegames]}-puzzlegames']").set "upupdowndownleftrightleftrightBAstart"
  end
end

shared_context 'enter information into large text field' do
  before do
    form = osp_page.osp_form
    form.find("form textarea[name='#{question_ids[:videogames]}-videogames']").set "upupdowndownleftrightleftrightBAstart"
  end
end


### Submitting osp form  ###

shared_context 'submit the osp form' do
  before do
    form = osp_page.osp_form
    form.submit.click if form.present?

  end

  after { clean_models UpdateQueue, OspFormResponse }
end

### Scoping subject  ###

shared_context 'within osp form' do
  subject { osp_page.osp_form }
end

shared_context 'within input field' do |esp_response_key|
  subject do
    form = osp_page.osp_form
    form.find("form input[name='#{question_ids[esp_response_key]}-#{esp_response_key.to_s}']")
  end
end

shared_context 'within textarea field' do |esp_response_key|
  subject do
    form = osp_page.osp_form
    form.find("form textarea[name='#{question_ids[esp_response_key]}-#{esp_response_key.to_s}']")
  end
end

shared_context 'the OspFormResponse objects\' responses in the db' do
  before { current_url } #buffers execution timing to prevent async issue. See queue_daemon_contexts
  subject do
    OspFormResponse.pluck(:response).map {|r| JSON.parse(r)}
  end
end

shared_context 'OSP nav should have an h3 with text' do |form|
  subject {find('h3', text: form)}
end

shared_context 'click OSP mobile nav' do |form|
  before do
    click_button 'Basic Information'
  end
  subject { find('.js-submitTrigger', text: form) }
end
