require 'spec_helper'
require_relative 'examples/user_profile_association'
require_relative 'examples/model_with_password'
require_relative 'examples/model_with_esp_memberships'
require_relative 'examples/model_with_subscriptions_association'
require_relative 'examples/model_with_favorite_schools_association'
require_relative 'examples/model_with_student_grade_levels_association'
require_relative 'examples/model_with_roles_association'

describe User do
  it_behaves_like 'user with user profile association'
  it_behaves_like 'model with password', :new_user
  it_behaves_like 'model with esp memberships'
  it_behaves_like 'model with subscriptions association'
  it_behaves_like 'model with favorite schools association'
  it_behaves_like 'model with student grade levels association'
  it_behaves_like 'model with roles association'

  context 'new user with valid password' do
    let!(:user) { FactoryGirl.build(:new_user) }
    before(:each) { clean_dbs :gs_schooldb }
    before(:each) { user.encrypt_plain_text_password }

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

end
