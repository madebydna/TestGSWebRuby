shared_examples_for 'model with roles association' do

  describe '#has_role' do
    let(:user) { FactoryGirl.create(:new_user) }
    let!(:esp_superuser_role) {FactoryGirl.build(:role,id:1 )}
    let!(:some_role) {FactoryGirl.build(:role,id:2 )}
    let!(:member_roles) {FactoryGirl.build_list(:member_role,1,member_id: user.id,role_id:2)}
    after { clean_dbs :gs_schooldb }

    it 'should return false, since the user has no member_roles' do
      allow(user).to receive(:member_roles).and_return(nil)
      expect(user.has_role?(esp_superuser_role)).to be_falsey
    end

    it 'should return false, since the user role id does not match' do
      allow(user).to receive(:member_roles).and_return(member_roles)
      expect(user.has_role?(esp_superuser_role)).to be_falsey
    end

    it 'should return true' do
      allow(user).to receive(:member_roles).and_return(member_roles)
      expect(user.has_role?(some_role)).to be_truthy
    end
  end

end