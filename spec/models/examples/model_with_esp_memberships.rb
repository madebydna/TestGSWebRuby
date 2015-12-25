shared_examples_for 'model with esp memberships' do

  describe '#is_esp_superuser' do
    let!(:user) { FactoryGirl.build(:new_user) }
    let!(:esp_superuser_role) {FactoryGirl.build(:role )}
    let!(:member_roles) {FactoryGirl.build_list(:member_role,1,member_id: user.id,role_id:esp_superuser_role.id)}
    after { clean_dbs :gs_schooldb }

    it 'should return false, since the user has no member_roles' do
      allow(Role).to receive(:esp_superuser).and_return(esp_superuser_role)
      allow(user).to receive(:member_roles).and_return(nil)
      expect(user.is_esp_superuser?).to be_falsey
    end

    it 'should return true, since user has a super user member_role' do
      allow(Role).to receive(:esp_superuser).and_return(esp_superuser_role)
      allow(user).to receive(:member_roles).and_return(member_roles)
      expect(user.is_esp_superuser?).to be_truthy
    end
  end

  describe '#provisional_or_approved_osp_user' do
    after { clean_dbs :gs_schooldb }
    subject!(:user) { FactoryGirl.create(:new_user) }
    it { is_expected.to_not be_provisional_or_approved_osp_user }

    context 'with an esp membership' do
      before do
        user.esp_memberships << esp_membership
        user.save
      end
      context 'with approved esp membership' do
        let(:esp_membership) { FactoryGirl.create(:esp_membership, :with_approved_status, member_id: user.id) }
        it { is_expected.to be_provisional_or_approved_osp_user }
      end
      context 'with approved esp membership for specific school' do
        let(:school) { FactoryGirl.create(:alameda_high_school) }
        after { clean_dbs :ca }
        let(:esp_membership) {
          FactoryGirl.create(
            :esp_membership,
            :with_approved_status,
            member_id: user.id,
            state: school.state,
            school_id: school.id
          )
        }
        it { is_expected.to_not be_provisional_or_approved_osp_user(School.new) }
        it { is_expected.to be_provisional_or_approved_osp_user(school) }
      end

      context 'with provisional esp membership' do
        let(:esp_membership) { FactoryGirl.create(:esp_membership, :with_provisional_status, member_id: user.id) }
        it { is_expected.to be_provisional_or_approved_osp_user }
      end
      context 'with provisional esp membership' do
        let(:esp_membership) { FactoryGirl.create(:esp_membership, :with_rejected_status, member_id: user.id) }
        it { is_expected.to_not be_provisional_or_approved_osp_user }
      end
    end
  end

  describe '#is_active_esp_member?' do
    after { clean_dbs :gs_schooldb }
    subject!(:user) { FactoryGirl.create(:new_user) }
    it { is_expected.to_not be_provisional_or_approved_osp_user }
    context 'when an esp superuser' do
      before { allow(user).to receive(:is_esp_superuser?).and_return(true) }
      it { is_expected.to be_is_active_esp_member }
    end
    context 'with an esp membership' do
      let!(:esp_membership) { FactoryGirl.create(:esp_membership, :with_approved_status, member_id: user.id) }
      before do
        user.esp_memberships << esp_membership
        user.save
      end
      it { is_expected.to be_is_active_esp_member }
    end
  end
end