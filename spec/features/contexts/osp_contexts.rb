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
    clean_models :gs_schooldb, User, EspMembership
  end
end

shared_context 'signed in approved superuser for school' do |state, school_id|
  before do
    factory_girl_options = {state: state, school_id: school_id}.delete_if {|_,v| v.nil?}
    super_user = FactoryGirl.create(:verified_user, :with_approved_superuser_membership, factory_girl_options)
    log_in_user(super_user)
  end

  after do
    clean_models :gs_schooldb, User, UserProfile, EspMembership, MemberRole, Role
  end
end

### School Blocks ###

shared_context 'Basic High School' do
  let(:school) { FactoryGirl.create(:school, id: 1, level_code: 'h') }
  after { clean_models :ca, School }
  end

shared_context 'Delaware public school' do
  let!(:school) { School.on_db(:de).create!(id: 1, type: 'public', state: 'de', city: 'Scotland', name: 'Hogwarts School of Witchcraft and Wizardry') }
  after { clean_models :de, School }
  end

shared_context 'Delaware charter school' do
  let!(:school) { School.on_db(:de).create(id: 1, type: 'charter', state: 'de', city: 'Pyrenees', name: 'Beauxbatons Academy of Magic') }
  after { clean_models :de, School }
  end

shared_context 'Delaware private school' do
  let!(:school) { School.on_db(:de).create(id: 1, type: 'private', state: 'de', city: 'Sweden', name: 'Durmstrang Institute') }
  after { clean_models :de, School }
end

### Navigation ###

shared_context 'visit OSP page' do
  include_context 'signed in approved osp user for school', :ca, 1
  include_context 'Basic High School'
  let(:osp_page) { OspPage.new }
  before do
    visit osp_page_path(page: 1, schoolId: school.id, state: school.state)
  end
  subject { page }
end

shared_context 'visit OSP superuser page' do
  include_context 'signed in approved superuser for school', :ca, 1
  include_context 'Basic High School'
  let(:osp_page) { OspPage.new }
  before do
    visit osp_page_path(page: 1, schoolId: school.id, state: school.state)
  end
  subject { page }
end

shared_context 'visit OSP page with inactive school' do
  let!(:school) { School.on_db(:ca).create(id: 1, name: 'Exceptional Death Eaters Academy', active: 0, state: 'ca') }
  let(:osp_page) { OspPage.new }
  after { clean_models :ca, School }
  before do
    visit osp_page_path(page: 1, schoolId: school.id, state: school.state)
  end
  subject { page }
end

shared_context 'visit my account page' do
  before do
    visit my_account_path
  end
  subject { page }
end

shared_context 'visit registration confirmation page' do
  include_context 'signed in approved osp user for school', :ca, 1
  include_context 'Basic High School'
  let(:osp_page) { OspPage.new }
  before do
    visit osp_confirmation_path(schoolId: school.id, state: school.state)
  end
  subject { page }
  end

shared_context 'visit registration page' do
  include_context 'signed in approved osp user for school', :ca, 1
  include_context 'Basic High School'
  let(:osp_page) { OspPage.new }
  before do
    visit osp_confirmation_path(schoolId: school.id, state: school.state)
  end
  subject { page }
end

shared_context 'visit registration page with no state or school' do
  before do
    visit osp_registration_path
  end
  subject { page }
  end

shared_context 'visit registration page with school state and school' do
  before do
    visit osp_registration_path(schoolId: school.id, state: school.state)
  end
  subject { page }
end

shared_context 'visit registration page as a public or charter DE as a not signed in osp user' do

  before do
    visit osp_registration_path(schoolId: school.id, state: school.state)
  end
  subject { page }
end

shared_context 'click osp nav link element with text:' do |text|
  before do
    button = osp_page.osp_nav.nav_buttons(text: text).first
    button.click
  end
end

shared_context 'fill in OSP Registration with valid values' do |email|
  before do
    fill_in(:email, with: email)
    fill_in(:password, with: 'password')
    fill_in(:password_verify, with: 'password')
    fill_in(:first_name, with: 'Dev')
    fill_in(:last_name, with: 'Eloper')
    fill_in(:school_website, with: 'www.schoolwebsite.com')
  end
end

shared_context 'with both email opt-ins selected' do
  # Do nothing. This is the default.
end

shared_context 'with an email opt-in unselected' do |list|
  before do
    subject.find(:xpath, "//input[@value='#{list}']").set(false)
  end
end

shared_context 'submit OSP Registration form' do
  before { click_button 'Sign up' }
  after { clean_models :gs_schooldb, User, Subscription, EspMembership }
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
      videogames:        6,
      award:             7,
      award_year:        8,
      date_picker:       9,
      tuition_low:       10,
      tuition_high:      11,
      tuition_year:      12,
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

      },
      {
          id: question_ids[:award_year],
          esp_response_key: :award_year,
          osp_question_group_id: nil,
          question_type: 'input_and_year',
          config: { #will be turned into json, so needs to be string
            'question_ids' => [question_ids[:award]]
          }.to_json
      },
      {
          id: question_ids[:tuition_year],
          esp_response_key: :tuition_year,
          osp_question_group_id: nil,
          question_type: 'input_and_year',
          config: { #will be turned into json, so needs to be string
                    'question_ids' => [question_ids[:tuition_low],question_ids[:tuition_high]],
                    'year_display' => 'Range'
          }.to_json
      },
      {
          id: question_ids[:date_picker],
          esp_response_key: :date_picker,
          osp_question_group_id: nil,
          question_type: 'date_picker'
      }
    ]
  end
# All Child Questions should go here
  let(:questions_without_display_conf) do
    [
      {
        id: question_ids[:award],
        esp_response_key: :award,
        question_type: 'input_and_year',
      },
      {
          id: question_ids[:tuition_low],
          esp_response_key: :tuition_low,
          question_type: 'input_and_year',
      },
      {
          id: question_ids[:tuition_high],
          esp_response_key: :tuition_high,
          question_type: 'input_and_year',
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
        videogames:        3,
        video_urls:        4,
        normal_text_field: 5,
        school_phone:      6,
        school_fax:        7
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
                    'data-parsley-type' => 'email'
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
                    'data-parsley-type' => 'email'
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
                    'data-parsley-type' => 'email'
                }
            }.to_json
        },
        {
            id: question_ids[:video_urls],
            esp_response_key: :video_urls,
            osp_question_group_id: nil,
            question_type: 'input_field_md',
            config: {
                'validations' => {
                    'data-parsley-youtubevimeotag' => ''
                }
            }.to_json
        },
        {
            id: question_ids[:normal_text_field],
            esp_response_key: :normal_text_field,
            osp_question_group_id: nil,
            question_type: 'input_field_md',
            config: {
                'validations' => {
                    'data-parsley-blockhtmltags' => ''
                }
            }.to_json
        },
        {
            id: question_ids[:school_phone],
            esp_response_key: :school_phone,
            osp_question_group_id: nil,
            question_type: 'input_field_sm',
            config: {
                'validations' => {
                    'data-parsley-phonenumber' => ''
                }
            }.to_json
        },
        {
            id: question_ids[:school_fax],
            esp_response_key: :school_fax,
            osp_question_group_id: nil,
            question_type: 'input_field_sm',
            config: {
                'validations' => {
                    'data-parsley-phonenumber' => ''
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
    [*try(:questions_without_display_conf)].each do |question|
      FactoryGirl.create(:osp_question, question)
    end
  end
  after { clean_models :gs_schooldb, OspQuestion, OspDisplayConfig }
end

shared_context 'with oddly formatted data in school cache for school' do |state, school_id|
  before do
    FactoryGirl.create(:school_cache_odd_formatted_esp_responses, state: state, school_id: school_id )
  end

  after do
    clean_models :gs_schooldb, SchoolCache
  end
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

shared_context 'enter following text into text field with name' do | text, name |
  before do
    form = osp_page.osp_form
    form.find("form input[type=text][name='#{question_ids[name]}-#{name}']").set text
  end
end

shared_context 'selecting the following option in select box with name' do | text, name |
  before do
    form = osp_page.osp_form
    form.find("form select[name='#{question_ids[name]}-#{name}']").set text
  end
end

shared_context 'enter information into medium text field' do
  before do
    form = osp_page.osp_form
    form.find("form textarea[name='#{question_ids[:puzzlegames]}-puzzlegames']").set "upupdowndownleftrightleftrightBAstart"
  end
  end

shared_context 'enter video url information into medium text field' do
  before do
    form = osp_page.osp_form
    form.find("form textarea[name='#{question_ids[:video_urls]}-video_urls']").set "upupdowndownleftrightleftrightBAstart"
  end
end

shared_context 'enter information into large text field' do
  before do
    form = osp_page.osp_form
    form.find("form textarea[name='#{question_ids[:videogames]}-videogames']").set "upupdowndownleftrightleftrightBAstart"
  end
end

shared_context 'find input field with name' do |name|
  before do
    form = osp_page.osp_form
    form.find("form input[name='#{question_ids[name]}-#{name}']")
  end
end


### Submitting osp form  ###

shared_context 'submit the osp form' do
  before do
    form = osp_page.osp_form
    form.submit.click if form.present?

  end

  after { clean_models :gs_schooldb, UpdateQueue, OspFormResponse }
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

shared_context 'within select box' do |esp_response_key|
  subject do
    form = osp_page.osp_form
    form.find("form select[name='#{question_ids[esp_response_key]}-#{esp_response_key.to_s}']")
  end
end

shared_context 'within textarea field' do |esp_response_key|
  subject do
    form = osp_page.osp_form
    form.find("form textarea[name='#{question_ids[esp_response_key]}-#{esp_response_key.to_s}']")
  end
end

shared_context 'within button(s) with the text(s)' do |button_text| #string or array
  subject do
    answers = Regexp.new([*button_text].join('|'))
    osp_page.osp_form.buttons(text: answers)
  end
end

shared_context 'the OspFormResponse objects\' responses in the db' do
  before { current_url } #buffers execution timing to prevent async issue. See queue_daemon_contexts
  subject do
    OspFormResponse.pluck(:response).map {|r| JSON.parse(r)}
  end
end

shared_context 'Within the h3 with text' do |form|
  subject {find('h3', text: form)}
end

shared_context 'click OSP mobile nav' do |form|
  before do
    click_button 'Basic Information'
  end
  subject { find('.js-submitTrigger', text: form) }
end
