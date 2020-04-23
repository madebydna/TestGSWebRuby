require 'spec_helper'

describe UserSubscriptions do
  # describe '#get' do
  #   let(:user) {FactoryBot.create(:verified_user)}
  #   let(:subscriptions) {Subscription::SUBSCRIPTIONS.keys}
  #   before {subscriptions.each {|list_type| FactoryBot.create(:subscription, user: user , list: list_type)}}

  #   after {clean_dbs :gs_schooldb}


  #   context 'when external code changes data from underneath class' do
  #     let(:subscription) do
  #       FactoryBot.create(:subscription, user: user , list: 'greatnews')
  #     end

  #     it 'the subscription is still returned because related data is memoized' do
  #       expect do
  #         Subscription.destroy_all
  #       end.to_not change { UserSubscriptions.new(user).get.size }
  #     end
  #   end

  #   context 'with different subscription types' do
  #     it 'successfully retrieves all user subscriptions' do
  #       expect(UserSubscriptions.new(user).get.sort).to eq(subscriptions.sort)
  #     end
  #   end

  #   context 'with a disallowed subscription type' do
  #     before {FactoryBot.create(:subscription, user: user , list: 'DeafPig')}
  #     it 'does not retrieve subscriptions not included in whitelist' do
  #       expect(UserSubscriptions.new(user).get.any? {|list_type| list_type == 'DeafPig'}).to be_falsey
  #     end
  #   end
  # end

end
