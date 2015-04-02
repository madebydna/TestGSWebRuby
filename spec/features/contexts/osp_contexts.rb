require 'spec_helper'
require_relative '../../../spec/support/shared_contexts_for_signed_in_users'
require 'features/selectors/osp_page'


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

shared_context 'visit OSP page' do
  include_context 'signed in approved osp user for school', :ca, 1
  let(:school) { FactoryGirl.create(:school, id: 1, level_code: 'h') }
  let(:osp_page) { OspPage.new }
  before do
    visit admin_osp_page_path(page:1,schoolId:school.id, state:school.state)
    # save_and_open_page
  end
  after do
    clean_models School
  end
  subject { page }
end

shared_context 'with a basic set of osp questions in db' do
  let(:questions) do
    [
      {
        esp_response_key: :before_after_care,
        osp_question_group_id: nil,
        question_type: 'multi_select',
        default_config: { #will be turned into json, so needs to be string
          'answers' => {
            "Before Care" => "before",
            "After Care" => "after",
          }
        }.to_json
      },
      {
        esp_response_key: :transportation,
        osp_question_group_id: nil,
        question_type: 'conditional_multi_select',
        default_config: { #will be turned into json, so needs to be string
          'answers' => {
            'Bus' => 'bus',
            'Canoe' => 'canoe',
            'Unicycle!!!' => 'unicycle'
          },
          'options' => {
            'text_label' => 'General'
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
  after { clean_models OspQuestion, OspDisplayConfig }
end

shared_context 'click the none option on a conditional multi select question group' do
  before do
    trigger = osp_page.disabledElementTrigger.first
    trigger.click if trigger.present?
  end
  subject do
    osp_page.disabledElementTarget
  end
end

shared_context 'click a value in a conditional multi select group and then clicking none' do
  before do
    button = osp_page.disabledElementTarget.first
    button.click if button.present?
  end

  include_context 'click the none option on a conditional multi select question group'
end

shared_context 'submit the osp form' do
  before do
    form = osp_page.ospPageForm
    form.submit.click if form.present?
  end

  after { clean_models UpdateQueue, OspFormResponse }
end

# Capybara seems to execute some commands asychounously.
# In this case, it doesn't wait for the request to finish before executing this block,
# So a form submission won't be able to save rows into the db before this block retrieves rows
# leaving this here for now, but will need to think of a clean way to still test this flow
shared_context 'the OspFormResponse objects\' responses in the db' do
  subject do
    OspFormResponse.pluck(:response).map {|r| JSON.parse(r)}
  end
end

shared_example 'should only contain none in the response' do
  fail unless subject.present?

  [*subject].each do |response|
    response.each do |key, answers|
      answers.each do |answer|
        expect(answer['value']).to match /none|neither/
      end
    end
  end
end
