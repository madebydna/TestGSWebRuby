shared_examples_for 'user with user profile association' do
  it { is_expected.to respond_to(:has_active_profile?) }
  it { is_expected.to respond_to(:has_inactive_profile?) }
  it { is_expected.to respond_to(:create_user_profile) }

  describe '#has_active_profile?' do
    after(:each) { clean_dbs :gs_schooldb }
    # User profile is created automatically
    let!(:user) { FactoryGirl.create(:user) }

    it 'should return true if there is active profile' do
      expect(user.has_active_profile?).to be_truthy
    end
    it 'should return false if there is no profile' do
      clean_models :gs_schooldb, UserProfile
      expect(user.has_active_profile?).to be_falsey
    end
    it 'should return false if there is an inactive profile' do
      user.user_profile.active = false
      user.user_profile.save
      expect(user.has_active_profile?).to be_falsey
    end
  end

  describe '#has_inactive_profile?' do
    after(:each) { clean_dbs :gs_schooldb }
    # User profile is created automatically
    let!(:user) { FactoryGirl.create(:user) }

    it 'should return false if there is active profile' do
      expect(user.has_inactive_profile?).to be_falsey
    end
    it 'should return false if there is no profile' do
      clean_models :gs_schooldb, UserProfile
      expect(user.has_inactive_profile?).to be_falsey
    end
    it 'should return true if there is an inactive profile' do
      user.user_profile.active = false
      user.user_profile.save
      expect(user.has_inactive_profile?).to be_truthy
    end
  end

  describe '#create_user_profile' do
    it 'should log exceptions' do
      user_profile_stub = Class.new
      allow(user_profile_stub).to receive(:create) { raise 'error' }
      allow(user_profile_stub).to receive(:where) { user_profile_stub }
      allow(user_profile_stub).to receive(:first) { nil }

      stub_const('UserProfile', user_profile_stub)
      expect(GSLogger).to receive(:error)
      expect{ subject.send(:create_user_profile) }.to raise_error
    end
  end
end