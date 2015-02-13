require 'spec_helper'

describe UserProfile do

  describe '#created' do
    after { clean_models User, UserProfile }
    let(:user) { FactoryGirl.build(:verified_user) }

    it 'should have a timestamp after model is saved' do
      user.save
      expect(user.user_profile).to be_present

      expect(user.user_profile.created).to be_present
      expect(user.user_profile.created).to be > Time.zone.parse('1970-01-01 00:00:00')
      expect(user.user_profile.created).to be_within(1.minutes).of(Time.now)
    end

    it 'should not be changed when user is updated' do
      user.save
      profile = user.user_profile

      expect do
        sleep(1.second)
        profile.save
        profile.reload
      end.to_not change { profile.created }
    end
  end

  describe '#updated' do
    after { clean_models User, UserProfile }
    let(:user) { FactoryGirl.build(:verified_user) }

    it 'should have a timestamp after model is saved' do
      user.save
      expect(user.user_profile).to be_present

      expect(user.user_profile.updated).to be_present
      expect(user.user_profile.updated).to be > Time.zone.parse('1970-01-01 00:00:00')
      expect(user.user_profile.updated).to be_within(1.minutes).of(Time.now)
    end

    it 'should be changed when user is updated' do
      pending('PT-1213: TODO: figure out why test fails intermittently')
      fail
      user.save
      profile = user.user_profile

      expect do
        sleep(1.second)
        profile.save
        profile.reload
      end.to change { profile.updated }
    end
  end

end
