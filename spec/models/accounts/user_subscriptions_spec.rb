require 'spec_helper'

describe UserSubscriptions do

  describe '#get' do
    after do
      clean_dbs :gs_schooldb
    end
    context 'when external code changes data from underneath class' do
      let(:user) { FactoryGirl.create(:verified_user) }
      let!(:subscription) do
        FactoryGirl.create(:subscription, user: user , list: 'greatnews')
      end

      it 'the subscription is still returned because related data is memoized' do
        expect do
          Subscription.destroy_all
        end.to_not change { UserSubscriptions.new(user).get.size }
      end
    end
  end

end
