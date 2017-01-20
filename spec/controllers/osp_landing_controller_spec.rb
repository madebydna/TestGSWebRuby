require 'spec_helper'
require 'controllers/contexts/osp_shared_contexts'

describe OspLandingController do
  describe '#dashboard' do
    it 'redirects to signin if no user' do
      get :dashboard
      expect(response).to redirect_to(signin_path)
    end

    context 'with a signed in user with no memberships' do
      let (:user) { FactoryGirl.create(:user) }
      after { clean_models User }
      before { allow(controller).to receive(:current_user).and_return(user) }

      it 'redirects to my account' do
        get :dashboard
        expect(response).to redirect_to(my_account_path)
      end
    end

    context 'when provided a state and schoolId parameter' do
      let (:user) { FactoryGirl.create(:user) }
      after { clean_models User }
      before { allow(controller).to receive(:current_user).and_return(user) }

      it 'redirects to the appropriate form page' do
        get :dashboard, state: 'ca', schoolId: 1
        expect(response).to redirect_to(osp_page_path(:state =>'ca', :schoolId => 1, :page => 1))
      end
    end

    with_shared_context 'user esp_membership status is', :approved do
      before { allow(controller).to receive(:current_user).and_return(current_user) }

      it 'approved, it redirects to appropriate form page' do
        get :dashboard
        expect(response).to redirect_to(osp_page_path(:state =>state, :schoolId => school_id, :page => 1))
      end
    end

    with_shared_context 'user esp_membership status is', :provisional do
      before { allow(controller).to receive(:current_user).and_return(current_user) }

      it 'provisional, it redirects to appropriate form page' do
        get :dashboard
        expect(response).to redirect_to(osp_page_path(:state =>state, :schoolId => school_id, :page => 1))
      end
    end

    with_shared_context 'user esp_membership status is', :super do
      before { allow(controller).to receive(:current_user).and_return(current_user) }

      it 'superuser, it renders the disambiguation dashboard' do
        get :dashboard
        expect(response).to render_template('osp/dashboard')
      end
    end

    context 'with two or more active memberships' do
      before do
        user = FactoryGirl.create(:user)
        allow(controller).to receive(:current_user).and_return(user)
        FactoryGirl.create(:esp_membership, :with_approved_status,school_id: 1,state: 'ca',member_id: user.id)
        FactoryGirl.create(:esp_membership, :with_approved_status,school_id: 2,state: 'ca',member_id: user.id)
      end
      after do
        clean_models User, EspMembership
      end

      it 'renders the disambiguation dashboard' do
        get :dashboard
        expect(response).to render_template('osp/dashboard')
      end
    end
  end

  describe '#single_membership' do
    let (:subject) { controller.send(:single_membership) }
    let (:user) { FactoryGirl.create(:user) }

    before { allow(controller).to receive(:current_user).and_return(user) }

    after do
      clean_models User, EspMembership
    end

    it 'returns an approved memberships if you have exactly one' do
      FactoryGirl.create(:esp_membership, :with_approved_status, school_id: 2, state: 'ca', member_id: user.id)

      expect(subject).to_not be_nil
      expect(subject.school_id).to eq(2)
    end

    it 'returns nil if you have more than one approved membership' do
      FactoryGirl.create(:esp_membership, :with_approved_status, school_id: 2, state: 'ca', member_id: user.id)
      FactoryGirl.create(:esp_membership, :with_approved_status, school_id: 1, state: 'ca', member_id: user.id)

      expect(subject).to be_nil
    end

    it 'returns a provisional membership if you have exactly one' do
      FactoryGirl.create(:esp_membership, :with_provisional_status, school_id: 2, state: 'ca', member_id: user.id)

      expect(subject).to_not be_nil
      expect(subject.school_id).to eq(2)
      expect(subject.provisional?).to be_truthy
    end

    it 'returns a provisional membership if you have more than one' do
      FactoryGirl.create(:esp_membership, :with_provisional_status, school_id: 2, state: 'ca', member_id: user.id)
      FactoryGirl.create(:esp_membership, :with_provisional_status, school_id: 1, state: 'ca', member_id: user.id)

      expect(subject).to_not be_nil
      expect(subject.provisional?).to be_truthy
    end

    it 'returns approved membership if you have exactly one along with some provisionals' do
      FactoryGirl.create(:esp_membership, :with_approved_status, school_id: 2, state: 'ca', member_id: user.id)
      FactoryGirl.create(:esp_membership, :with_provisional_status, school_id: 1, state: 'ca', member_id: user.id)

      expect(subject).to_not be_nil
      expect(subject.school_id).to eq(2)
      expect(subject.approved?).to be_truthy
    end

    it 'returns nil if you have multiple approved memberships and one provisional' do
      FactoryGirl.create(:esp_membership, :with_approved_status, school_id: 2, state: 'ca', member_id: user.id)
      FactoryGirl.create(:esp_membership, :with_approved_status, school_id: 1, state: 'ca', member_id: user.id)
      FactoryGirl.create(:esp_membership, :with_provisional_status, school_id: 3, state: 'ca', member_id: user.id)

      expect(subject).to be_nil
    end

    it 'returns nil if you have no memberships' do
      expect(subject).to be_nil
    end
  end

  describe '#schools' do
    let (:subject) { controller.send(:schools) }

    before do
      user = FactoryGirl.create(:user)
      allow(controller).to receive(:current_user).and_return(user)
      FactoryGirl.create(:esp_membership, :with_approved_status, school_id: 10, state: 'ca', member_id: user.id)
      FactoryGirl.create(:esp_membership, :with_approved_status, school_id: 11, state: 'ca', member_id: user.id)
      FactoryGirl.create(:esp_membership, :with_approved_status, school_id: 12, state: 'ca', member_id: user.id)
    end

    after do
      clean_models User, EspMembership, School
    end

    it 'Orders schools by name' do
      s1 = FactoryGirl.create(:school, id: 10, name: 'Def')
      s2 = FactoryGirl.create(:school, id: 11, name: 'Ghi')
      s3 = FactoryGirl.create(:school, id: 12, name: 'Abc')

      expect(subject).to eq([s3, s1, s2])
    end

    it 'Removes nil (school not found)' do
      s2 = FactoryGirl.create(:school, id: 11, name: 'Ghi')
      s3 = FactoryGirl.create(:school, id: 12, name: 'Abc')

      expect(subject).to eq([s3, s2])
    end

    it 'Removes inactive schools' do
      s1 = FactoryGirl.create(:school, id: 10, name: 'Def')
      s2 = FactoryGirl.create(:school, id: 11, name: 'Ghi')
           FactoryGirl.create(:school, id: 12, name: 'Abc', active: false)

      expect(subject).to eq([s1, s2])
    end
  end
end