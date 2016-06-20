require 'spec_helper'

describe Subscription do

  describe '.archive_subscription' do
    after do
      clean_dbs :gs_schooldb
    end
    let(:now) { Time.now.strftime("%F %T") }
    let(:expires) { (Time.now + 1.days).strftime("%F %T") }
    let(:subscription) do
      FactoryGirl.create(:subscription,
                         list: 'foo',
                         member_id: 2,
                         school_id: 3,
                         state: 'CA',
                         updated: now,
                         expires: expires
                        )
    end
    it 'should archive a subscription with correct attributes' do
      SubscriptionHistory.archive_subscription(subscription)
      archived_subscriptions = SubscriptionHistory.all
      expect(archived_subscriptions.length).to eq(1)

      hash = archived_subscriptions[0].attributes

      expected_values = {
        'list' => 'foo',
        'member_id' => 2,
        'school_id' => 3,
        'state' => 'CA',
        'list_active_updated' => subscription.updated,
        'expires' => subscription.expires
      }
      expected_values.each_pair do |key, value|
        expect(hash[key]).to eq(value)
      end
    end
  end

end
