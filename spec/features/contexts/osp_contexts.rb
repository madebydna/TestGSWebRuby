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
  let(:question_keys_and_answers) do
    {
      'before_after_care' => {
        "Before Care"=>"before",
        "After Care"=>"after",
      }
    }
  end

  let(:optional_factory_girl_config) do
    {
      osp_question_group_id: nil,
      question_type: 'conditional_multi_select'
    }
  end

  include_context 'save osp question to db'
end

shared_context 'save osp question to db' do
  before do
    question_keys_and_answers.each do |key, answers|
      config = { "answers"=> answers }.to_json
      factory_girl_hash = {
        esp_response_key: key,
        default_config: config
      }
      factory_girl_hash.merge!(optional_factory_girl_config) if optional_factory_girl_config.present?

      FactoryGirl.create(:osp_question, :with_osp_display_config, factory_girl_hash)
    end
  end
  after { clean_models OspQuestion, OspDisplayConfig }
end

shared_context 'when clicking the none option on a question group' do
  before do
    trigger = osp_page.disabledElementTrigger.first
    trigger.click if trigger.present?
  end
  subject do
    osp_page.disabledElementTarget
  end
end
