require 'spec_helper'

describe Admin::OspModerationController do

  let(:school) { FactoryBot.create(:school) }
  let(:user) { FactoryBot.create(:verified_user) }
  let(:esp_membership) { FactoryBot.create(:esp_membership, state: 'ca', school_id: school.id, member_id: user.id) }
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

  describe 'with non-unique user email' do
    it 'returns an email validation error' do
      user2 = FactoryBot.build(:user, email: user.email)
      user2.valid?
      expect(user2.errors[:email]).to include("Sorry, but the email you chose has already been taken.")
    end
  end

end
