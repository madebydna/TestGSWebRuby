require 'spec_helper'

describe Admin::OspController do

  let(:current_user) { FactoryGirl.build(:user) }
  let(:school) { FactoryGirl.create(:alameda_high_school) }

  describe '#show' do
    before do
      controller.instance_variable_set(:@current_user, current_user)
    end
    after do
      clean_models School
    end
    it 'should redirect user to account page if user does not have access to osp' do
      allow(current_user).to receive(:provisional_or_approved_osp_user?).and_return false
      get :show, state: school.state, schoolId: school.id
      expect(response).to redirect_to(my_account_url)
      end

    it 'should render Basic Information page if user has access to osp' do
      allow(current_user).to receive(:provisional_or_approved_osp_user?).and_return true
      get :show, state: school.state, schoolId: school.id, page: 1
      expect(response).to render_template('osp/osp_basic_information')
      end

    it 'should render Academics page if user has access to osp' do
      allow(current_user).to receive(:provisional_or_approved_osp_user?).and_return true
      get :show, state: school.state, schoolId: school.id, page: 2
      expect(response).to render_template('osp/osp_academics')
      end

    it 'should render Extracurricular & Culture  page if user has access to osp' do
      allow(current_user).to receive(:provisional_or_approved_osp_user?).and_return true
      get :show, state: school.state, schoolId: school.id, page: 3
      expect(response).to render_template('osp/osp_extracurricular_culture')
    end

    it 'should render Facilities & Staff  page if user has access to osp' do
      allow(current_user).to receive(:provisional_or_approved_osp_user?).and_return true
      get :show, state: school.state, schoolId: school.id, page: 4
      expect(response).to render_template('osp/osp_facilities_staff')
    end
  end


end