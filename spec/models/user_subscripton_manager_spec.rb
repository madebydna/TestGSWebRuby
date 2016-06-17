require 'spec_helper'

describe UserSubscriptionManager do

  # this tests if a subcription is save or deleted but is not testing 
  # that the correct subscripton is being changed
  # You might want more specific tests for that and could replace these

  describe '#update' do
    before { clean_dbs(:gs_schooldb) }
    let(:user) { FactoryGirl.create(:user) }
    context 'with no prior subscriptions' do
      it 'should add new subscription when given a new subscription' do
        new_subscription_ids = ['greatnews']
        expect do
          UserSubscriptionManager.new(user).update(new_subscription_ids)
        end.to change{user.subscriptions.count}.from(0).to(1)
      end
    end

    context 'with user unsubcribing from subscription' do
      let!(:current_subscription) { FactoryGirl.create(:subscription, member_id: user.id) }
      it 'should remove subscription for user' do
        no_subscriptions = []
        expect do
          UserSubscriptionManager.new(user).update(no_subscriptions)
        end.to change{user.subscriptions.count}.from(1).to(0)
      end
    end
  end

  describe '#unsubscribe' do
    context 'as user with subscriptions' do
      it 'should remove all subscriptions for that user' do


      end
    end
  end

end
