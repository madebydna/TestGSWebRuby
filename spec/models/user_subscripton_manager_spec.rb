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

    context 'with greatnews subscription' do
      let!(:current_subscription) do
        FactoryGirl.create(:subscription, member_id: user.id, list: 'greatnews')
      end
      let(:subscription_manager) { UserSubscriptionManager.new(user) }
      subject { subscription_manager.update(chosen_lists) }

      context 'when choosing to have a greatnews subscription' do
        let(:chosen_lists) { ['greatnews'] }

        it 'should handle request to keep greatnews subscription' do
          expect(user.subscriptions.count).to eq(1)
          expect { subject }.to_not change { user.subscriptions.count }
        end

        it 'not send the same list to both delete and save' do
          subscriptions_that_manager_tried_to_delete = []
          subscriptions_that_manager_tried_to_save = []
          allow(subscription_manager).to receive(:delete_subscriptions) do |lists|
            lists.each { |l| subscriptions_that_manager_tried_to_delete << l.to_s }
          end
          allow(subscription_manager).to receive(:save_subscriptions) do |lists|
            lists.each { |l| subscriptions_that_manager_tried_to_save << l.to_s }
          end
          subject
          intersection = (subscriptions_that_manager_tried_to_delete & 
            subscriptions_that_manager_tried_to_save)
          expect(intersection).to be_empty
        end
      end

      context 'when choosing not to have any subscriptions' do
        let(:chosen_lists) { [] }

        it 'deletes the correct subscriptions' do
          subject
          expect(user.subscriptions.count).to eq(0)
        end
      end

      context 'when choosing to add an addition subscription' do
        let(:chosen_lists) { ['greatkids','greatnews'] }
        it 'should add the correct subscription' do
          subject
          expect(user.subscriptions.count).to eq(2)
        end
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
