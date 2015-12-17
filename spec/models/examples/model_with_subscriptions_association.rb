shared_examples_for 'model with subscriptions association' do

  it 'should have subscriptions association' do
    association = User.reflect_on_association(:subscriptions)
    expect(association.macro).to eq(:has_many)
  end

  describe '#safely_add_subscription!' do
    after do
      clean_dbs :gs_schooldb, :ca
    end
    let(:user) { FactoryGirl.create(:verified_user) }
    [
      [ 'osp_partner_promos', nil, nil ],
      [ 'mystat', 'CA', 1000 ],
      [ 'mystat_private', 'CA', 1000 ],
      [ 'osp', nil, nil ],
    ].each do |opts|
      list = opts.first
      it "should try to create only one list with: #{opts.to_s}" do
        subscription_school = FactoryGirl.create(:school, state: opts[1], id: opts[2]) if opts[1] && opts[2]
        expect_any_instance_of(Subscription).to receive(:save!).once.and_call_original
        2.times { user.safely_add_subscription!(list, subscription_school) }
      end
    end

    it 'should allow the same list for multiple schools' do
      schools = FactoryGirl.create_list(:school, 2)
      expect do
        schools.each do |school|
          user.safely_add_subscription!('mystat', school)
        end
      end.to change { user.subscriptions.size }.from(0).to(2)
    end
  end

  describe '#new_subscription!' do
    let(:now) { Time.now }

    it 'sets default state and school id when no school provided' do
      subscription = subject.new_subscription(:mystat)
      expect(subscription.state).to eq('CA')
      expect(subscription.school_id).to eq(0)
    end

    it 'defaults expires to nil when no expiration set' do
      subscription_product = Subscription::SubscriptionProduct.new('mystat', 'My School Stats','A description', nil, true)
      allow(Subscription).to receive(:subscription_product).with(:mystat).and_return(subscription_product)
      subscription = subject.new_subscription(:mystat)
      expect(subscription.expires).to be_nil
    end

    it 'should perform expiration date math correctly' do
      subscription_product = Subscription::SubscriptionProduct.new('mystat', 'My School Stats','A description', 1.year, true)

      allow(Subscription).to receive(:subscription_product).with(:mystat).and_return(subscription_product)

      subscription = subject.new_subscription(:mystat)
      expires = subscription.expires
      expect(expires.year).to eq(now.year + 1)
      expect(expires.month).to eq(now.month)
      expect(expires.day).to eq(now.day)
    end

    it 'raises an exception if it can\'t find subscription_product' do
      expect{ subject.new_subscription 'bogus' }.to raise_error
    end
  end

  describe 'check if subject has subscription' do
    it 'has the subscription already' do
      subscriptions = []
      subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'ca', school_id: 1, expires: 10.days.from_now)
      subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'mi', school_id: 1, expires: 10.days.from_now)
      subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat_private', state: 'ca', school_id: 2, expires: 10.days.from_now)
      allow(subject).to receive(:subscriptions).and_return(subscriptions)

      school = FactoryGirl.build_stubbed(:school_with_params, id: 1, state: 'mi')

      expect(subject.has_subscription?('mystat', school)).to be_truthy
    end

    it "does not have the subscription already, because the school's state is different" do
      subscriptions = []
      subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'ca', school_id: 1, expires: 10.days.from_now)
      subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'mi', school_id: 1, expires: 10.days.from_now)
      subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat_private', state: 'ca', school_id: 2, expires: 10.days.from_now)
      allow(subject).to receive(:subscriptions).and_return(subscriptions)

      school = FactoryGirl.build_stubbed(:school_with_params, id: 1, state: 'tx')

      expect(subject.has_subscription?('mystat', school)).to be_falsey
    end

    it 'does not have the subscription already, because the subscription has expired' do
      subscriptions = []
      subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'ca', school_id: 1, expires: 10.days.from_now)
      subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'mi', school_id: 1, expires: Time.now - 10.days)
      subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat_private', state: 'ca', school_id: 2, expires: 10.days.from_now)

      allow(subject).to receive(:subscriptions).and_return(subscriptions)

      school = FactoryGirl.build_stubbed(:school_with_params, id: 1, state: 'mi')

      expect(subject.has_subscription?('mystat', school)).to be_falsey
    end
  end


end