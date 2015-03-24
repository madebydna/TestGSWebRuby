require 'spec_helper'

describe Admin::OspController do

  let(:current_user) { FactoryGirl.build(:user) }
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  before do
    controller.instance_variable_set(:@current_user, current_user)
    allow(School).to receive(:find_by_state_and_id).and_return school
  end
  after do
    clean_models School
  end

  describe '#show' do

    it 'should redirect user to account page if user does not have access to osp' do
      allow(current_user).to receive(:provisional_or_approved_osp_user?).and_return false

      get :show, state: school.state, schoolId: school.id
      expect(response).to redirect_to(my_account_url)
    end

    {
        osp_basic_information: 1, #page number
        osp_academics: 2,
        osp_extracurricular_culture: 3,
        osp_facilities_staff: 4
    }.each do |page, page_number|
      it "should render #{page} page if user has access to osp and page is #{page_number}" do
        allow(current_user).to receive(:provisional_or_approved_osp_user?).and_return true
        get :show, state: school.state, schoolId: school.id, page: page_number
        expect(response).to render_template(page)
      end
    end
  end

  describe '#submit' do
    before do
      allow(current_user).to receive(:provisional_or_approved_osp_user?).and_return true
    end
    {
        osp_basic_information: 1, #page number
        osp_academics: 2,
        osp_extracurricular_culture: 3,
        osp_facilities_staff: 4
    }.each do |page, page_number|
      it "should redirect user back to #{page} page when submit is clicked on the #{page} page" do
        get :show, state: school.state, schoolId: school.id, page: page_number
        expect(response).to render_template(page)
      end
    end
  end
end