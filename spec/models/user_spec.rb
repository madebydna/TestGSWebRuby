require 'spec_helper'
require_relative 'examples/user_profile_association'
require_relative 'examples/model_with_password'

describe User do
  it_behaves_like 'user with user profile association'
  it_behaves_like 'model with password', :new_user

  context 'new user with valid password' do
    let!(:user) { FactoryGirl.build(:new_user) }
    before(:each) { clean_dbs :gs_schooldb }
    before(:each) { user.encrypt_plain_text_password }

    it 'should be able to have subscriptions' do
      association = User.reflect_on_association(:subscriptions)
      expect(association.macro).to eq(:has_many)
    end

    it 'should be provisional after being saved' do
      user.save!
      expect(user).to be_provisional
    end

    it 'allows valid password to be saved' do
      user.password = 'password'
      expect(user.save).to be_truthy
    end

    it 'throws validation error if password too short' do
      user.password = 'pass'
      user.encrypt_plain_text_password
      expect{user.save!}.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should have a value for time_added' do
      expect(user.time_added).to_not be_nil
    end

    describe '#new_subscription!' do
      let(:user) { FactoryGirl.build(:user) }
      let(:now) { Time.now }

      it 'sets default state and school id when no school provided' do
        subscription = user.new_subscription(:mystat)
        expect(subscription.state).to eq('CA')
        expect(subscription.school_id).to eq(0)
      end

      it 'defaults expires to nil when no expiration set' do
        subscription_product = Subscription::SubscriptionProduct.new('mystat', 'My School Stats','A description', nil, true)
        allow(Subscription).to receive(:subscription_product).with(:mystat).and_return(subscription_product)
        subscription = user.new_subscription(:mystat)
        expect(subscription.expires).to be_nil
      end

      it 'should perform expiration date math correctly' do
        subscription_product = Subscription::SubscriptionProduct.new('mystat', 'My School Stats','A description', 1.year, true)

        allow(Subscription).to receive(:subscription_product).with(:mystat).and_return(subscription_product)

        subscription = user.new_subscription(:mystat)
        expires = subscription.expires
        expect(expires.year).to eq(now.year + 1)
        expect(expires.month).to eq(now.month)
        expect(expires.day).to eq(now.day)
      end

      it 'raises an exception if it can\'t find subscription_product' do
        expect{ user.new_subscription 'bogus' }.to raise_error
      end
    end

    describe 'check if user has subscription' do
      it 'has the subscription already' do
        subscriptions = []
        subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'ca', school_id: 1, expires: 10.days.from_now)
        subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'mi', school_id: 1, expires: 10.days.from_now)
        subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat_private', state: 'ca', school_id: 2, expires: 10.days.from_now)
        allow(user).to receive(:subscriptions).and_return(subscriptions)

        school = FactoryGirl.build_stubbed(:school_with_params, id: 1, state: 'mi')

        expect(user.has_subscription?('mystat', school)).to be_truthy
      end

      it "does not have the subscription already, because the school's state is different" do
        subscriptions = []
        subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'ca', school_id: 1, expires: 10.days.from_now)
        subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'mi', school_id: 1, expires: 10.days.from_now)
        subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat_private', state: 'ca', school_id: 2, expires: 10.days.from_now)
        allow(user).to receive(:subscriptions).and_return(subscriptions)

        school = FactoryGirl.build_stubbed(:school_with_params, id: 1, state: 'tx')

        expect(user.has_subscription?('mystat', school)).to be_falsey
      end

      it 'does not have the subscription already, because the subscription has expired' do
        subscriptions = []
        subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'ca', school_id: 1, expires: 10.days.from_now)
        subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat', state: 'mi', school_id: 1, expires: Time.now - 10.days)
        subscriptions << FactoryGirl.build_stubbed(:subscription, list: 'mystat_private', state: 'ca', school_id: 2, expires: 10.days.from_now)

        allow(user).to receive(:subscriptions).and_return(subscriptions)

        school = FactoryGirl.build_stubbed(:school_with_params, id: 1, state: 'mi')

        expect(user.has_subscription?('mystat', school)).to be_falsey
      end
    end

    describe '#validate_email_verification_token' do
      before(:each) do
        @token, @time = user.email_verification_token
      end

      it 'returns false when given nils and blanks' do
        expect(User.validate_email_verification_token nil, nil).to be_falsey
        expect(User.validate_email_verification_token '', nil).to be_falsey
        expect(User.validate_email_verification_token nil, '').to be_falsey
        expect(User.validate_email_verification_token '', '').to be_falsey
      end

      it 'returns false for malformed token' do
        expect(User.validate_email_verification_token 'not_a_valid_token', @time.to_s).to be_falsey
        longer_token = (1..24).to_a.join
        expect(User.validate_email_verification_token longer_token, @time.to_s).to be_falsey
      end

      describe 'with a valid token' do

        it 'returns a user when it gets a valid token and date' do
          allow(User).to receive(:find).and_return(user)

          verified_user = User.validate_email_verification_token @token, @time

          expect(verified_user).to eq(user)
          expect(user).to be_email_verified
        end

        it 'returns false if date is expired' do
          expired_date = Time.now - EmailVerificationToken::EMAIL_TOKEN_EXPIRATION
          expect(User.validate_email_verification_token @token, expired_date).to be_falsey
        end

        it 'returns false if date is in the future' do
          expired_date = Time.now + 1.day
          expect(User.validate_email_verification_token @token, expired_date).to be_falsey
        end

        it 'returns false if date is malformed' do
          expect(User.validate_email_verification_token @token, 'not_a_valid_date').to be_falsey
        end
      end
    end

    describe '#active_reviews_for_school' do
      let(:state) { 'ca' }
      let(:school_id) { 10 }
      let(:school) { FactoryGirl.build(:school, id: school_id, state: state) }

      it 'should support a school hash parameter' do
        relation = double
        expect(Review).to receive(:where).with(active: true, school_state: state, school_id: school_id).and_return(relation)
        expect(relation).to receive(:where).with(member_id: subject.id)
        subject.active_reviews_for_school(school: school)
      end

      it 'should support state + school_id parameters' do
        relation = double
        expect(Review).to receive(:where).with(active: true, school_state: state, school_id: school_id).and_return(relation)
        expect(relation).to receive(:where).with(member_id: subject.id)
        subject.active_reviews_for_school(state: state, school_id: school_id)
      end

      it 'should raise error for invalid arguments' do
        expect(SchoolRating).to_not receive(:where)
        expect{ subject.active_reviews_for_school(nil) }.to raise_error
      end

      context 'with saved school and an active and inactive review' do
        let(:user) { FactoryGirl.create(:verified_user) }
        let(:school) { FactoryGirl.create(:alameda_high_school) }
        let(:review1) do
          review1 = FactoryGirl.create(:five_star_review, user: user, school: school)
          review1.moderated = true
          review1.deactivate
          review1.save
          review1
        end
        let(:review2) do
          review2 = FactoryGirl.create(:five_star_review, user: user, school: school)
          review2.moderated = true
          review2.activate
          review2.save
          review2
        end
        let(:reviews) do
          [
            review1,
            review2
          ]
        end
        after do
          clean_models User, School, Review
        end

        it 'should return only active reviews' do
          expect(user.active_reviews_for_school(school)).to eq([review2])
        end
      end
    end

    describe '#reviews_for_school' do
      context 'with saved school and an active and inactive review' do
        let!(:user) { FactoryGirl.create(:verified_user) }
        let!(:school) { FactoryGirl.create(:alameda_high_school) }
        let!(:review1) do
          review1 = FactoryGirl.create(:five_star_review, user: user, school: school)
          review1.moderated = true
          review1.deactivate
          review1.save
          review1
        end
        let!(:review2) do
          review2 = FactoryGirl.create(:five_star_review, user: user, school: school)
          review2.moderated = true
          review2.activate
          review2.save
          review2
        end
        let(:reviews) do
          [
            review1,
            review2
          ]
        end
        after do
          clean_models User, School, Review
        end

        it 'should return all reviews' do
          expected_array = [review1, review2].sort
          expect(user.reviews_for_school(school).to_a.sort).to eq(expected_array)
        end
      end
    end

    describe '#is_esp_superuser' do
      let!(:esp_superuser_role) {FactoryGirl.build(:role )}
      let!(:member_roles) {FactoryGirl.build_list(:member_role,1,member_id: user.id,role_id:esp_superuser_role.id)}

      it 'should return false, since the user has no member_roles' do
        allow(Role).to receive(:esp_superuser).and_return(esp_superuser_role)
        allow(user).to receive(:member_roles).and_return(nil)
        expect(user.is_esp_superuser?).to be_falsey
      end


      it 'should return true, since user has a super user member_role' do
        allow(Role).to receive(:esp_superuser).and_return(esp_superuser_role)
        allow(user).to receive(:member_roles).and_return(member_roles)
        expect(user.is_esp_superuser?).to be_truthy
      end
    end

    describe '#has_role' do
      let!(:esp_superuser_role) {FactoryGirl.build(:role,id:1 )}
      let!(:some_role) {FactoryGirl.build(:role,id:2 )}
      let!(:member_roles) {FactoryGirl.build_list(:member_role,1,member_id: user.id,role_id:2)}

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

    describe '#time_added' do
      after { clean_models User }

      it 'should be less than or equal to the "updated" timestamp after first save' do
        u = FactoryGirl.build(:new_user)
        u.save
        u.reload
        expect(u.time_added).to be_present
        expect(u.updated).to be_present
        expect(u.updated).to eq(u.time_added)
      end

      it 'should not be changed when user is updated' do
        u = FactoryGirl.build(:new_user)
        u.save
        u.reload
        expect do
          u.first_name = 'Foo'
          u.save
          u.reload
        end.to_not change { u.time_added }
      end

      it 'should never be greater than "updated" timestmap' do
        u = FactoryGirl.build(:new_user)
        u.save
        u = User.find(u.id)
        sleep(1.second)
        u.save
        u.reload
        expect(u.time_added).to be_present
        expect(u.updated).to be_present
        expect(u.updated).to be >= u.time_added
      end
    end


    describe '#publish_reviews!' do
      let(:school) do
        FactoryGirl.create(:alameda_high_school)
      end
      let(:question) do
        FactoryGirl.create(:overall_rating_question)
      end
      let!(:existing_reviews) do
        reviews = [
          FactoryGirl.create(:five_star_review, active: false, school: school, question:question, user: user, created: '2010-01-01'),
          FactoryGirl.create(:five_star_review, active: false, school: school, question:question, user: user, created: '2011-01-01'),
          FactoryGirl.create(:five_star_review, active: false, school: school, question:question, user: user, created: '2012-01-01'),
        ]
        reviews.each do
        |review| review.moderated = true
          review.save
        end
        reviews
      end
      after do
        clean_models School
        clean_dbs :gs_schooldb
      end
      subject { user }

      it 'should publish the most recent inactive review' do
        user.verify_email!
        user.save
        subject.publish_reviews!
        existing_reviews.each(&:reload)
        expect(existing_reviews[0]).to be_inactive
        expect(existing_reviews[1]).to be_inactive
        expect(existing_reviews[2]).to be_active
      end
    end
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

    it "should allow the same list for multiple schools" do
      schools = FactoryGirl.create_list(:school, 2)
      expect do
        schools.each do |school|
          user.safely_add_subscription!('mystat', school)
        end
      end.to change { user.subscriptions.size }.from(0).to(2)
    end
  end

end
