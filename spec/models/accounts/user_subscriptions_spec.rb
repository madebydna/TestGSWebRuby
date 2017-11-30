require 'spec_helper'

describe UserSubscriptions do

  describe '#get' do
    user = FactoryGirl.create(:verified_user)
    subscriptions = Subscription::SUBSCRIPTIONS.map(&:first)
    subscriptions.each {|list_type| FactoryGirl.create(:subscription, user: user , list: list_type)}

    after do
      clean_dbs :gs_schooldb
    end

    context 'when external code changes data from underneath class' do
      let!(:subscription) do
        FactoryGirl.create(:subscription, user: user , list: 'greatnews')
      end

      it 'the subscription is still returned because related data is memoized' do
        expect do
          Subscription.destroy_all
        end.to_not change { UserSubscriptions.new(user).get.size }
      end
    end

    context 'with different subscription types' do
      it 'successfully retrieves all user subscriptions' do
        expect(UserSubscriptions.new(user).get.sort).to eq(subscriptions.sort)
      end
    end

    context 'with a disallowed subscription type' do
      FactoryGirl.create(:subscription, user: user , list: 'DeafPig')
      it 'does not retrieve subscriptions not included in whitelist' do
        expect(UserSubscriptions.new(user).get.any? {|list_type| list_type == 'DeafPig'}).to be_falsey
      end
    end
  end

end
