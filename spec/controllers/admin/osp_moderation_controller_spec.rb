require 'spec_helper'

describe Admin::OspModerationController do

  let(:school) { FactoryGirl.create(:school) }
  let(:user) { FactoryGirl.create(:verified_user) }
  let(:esp_membership) { FactoryGirl.create(:esp_membership, :with_approved_status, member_id: user.id) }
  after { clean_dbs :gs_schooldb }

  it 'should have the right methods' do
    expect(controller).to respond_to :update
    expect(controller).to respond_to :update_osp_list_member
  end

  describe "GET edit" do
    it "renders the edit template" do
      get :edit, {id: esp_membership.id.to_s}
      expect(response).to render_template('osp/osp_moderation/edit')
    end

  end


  describe '#update_osp_list_member' do
    describe 'with non-unique user email' do
      it 'returns a validation error' do
        user2 = FactoryGirl.build(:user, email: user.email)
        user2.valid?
        expect(user2.errors[:email]).to include("Sorry, but the email you chose has already been taken.")
      end
    end

    describe 'with unique user email' do
      it 'successfully updates user email' do

      end
    end

    describe 'on update' do
      it 'inserts the current date/time in the updated column' do

      end

      it 'updates updates user info' do

      end
    end

  end
end