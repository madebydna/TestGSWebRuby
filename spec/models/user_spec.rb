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
    after(:each) { clean_dbs :gs_schooldb }
    before { user.encrypt_plain_text_password }

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
        clean_models :ca, School
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

      context 'when an older review is already published' do
        let!(:existing_reviews) do
          reviews = [
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2010-01-01'),
            FactoryGirl.build(:five_star_review, active: true, school: school, question:question, user: user, created: '2011-01-01'),
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2012-01-01'),
          ]
          reviews.each do
          |review| review.moderated = true
            review.save
          end
          reviews
        end
        it 'should not publish most recent inactive review' do
          user.verify_email!
          user.save
          subject.publish_reviews!
          existing_reviews.each(&:reload)
          expect(existing_reviews[0]).to be_inactive
          expect(existing_reviews[1]).to be_active
          expect(existing_reviews[2]).to be_inactive
        end
      end

      context 'when the newest review is active and has been flagged' do
        let!(:existing_reviews) do
          reviews = [
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2010-01-01'),
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2011-01-01'),
            FactoryGirl.build(:five_star_review, active: true, school: school, question:question, user: user, created: '2012-01-01'),
          ]
          reviews.each do
          |review| review.moderated = true
            review.save
          end
          flag_builder = Review::ReviewFlagBuilder.new(reviews.last)
          flag_builder.reasons << 'auto-flagged' 
          flag_builder.build.save
          reviews
        end
        it 'should not publish any reviews' do
          user.verify_email!
          user.save
          subject.publish_reviews!
          existing_reviews.each(&:reload)
          expect(existing_reviews[0]).to be_inactive
          expect(existing_reviews[1]).to be_inactive
          expect(existing_reviews[2]).to be_active
        end
      end
      context 'when the newest review is inactive and has been flagged' do
        let!(:existing_reviews) do
          reviews = [
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2010-01-01'),
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2011-01-01'),
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2012-01-01'),
          ]
          reviews.each do
          |review| review.moderated = true
            review.save
          end
          flag_builder = Review::ReviewFlagBuilder.new(reviews.last)
          flag_builder.reasons << 'auto-flagged' 
          flag_builder.build.save
          reviews
        end
        it 'should publish the most recent inactive non-flagged review' do
          user.verify_email!
          user.save
          subject.publish_reviews!
          existing_reviews.each(&:reload)
          expect(existing_reviews[0]).to be_inactive
          expect(existing_reviews[1]).to be_active
          expect(existing_reviews[2]).to be_inactive
        end
      end
      context 'when an older review is inactive and has been flagged' do
        let!(:existing_reviews) do
          reviews = [
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2010-01-01'),
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2011-01-01'),
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2012-01-01'),
          ]
          reviews.each do
          |review| review.moderated = true
            review.save
          end
          flag_builder = Review::ReviewFlagBuilder.new(reviews[1])
          flag_builder.reasons << 'auto-flagged' 
          flag_builder.build.save
          reviews
        end
        it 'should publish the most recent inactive non-flagged review' do
          user.verify_email!
          user.save
          subject.publish_reviews!
          existing_reviews.each(&:reload)
          expect(existing_reviews[0]).to be_inactive
          expect(existing_reviews[1]).to be_inactive
          expect(existing_reviews[2]).to be_active
        end
      end

      context 'when an older review is active and has been flagged' do
        let!(:existing_reviews) do
          reviews = [
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2010-01-01'),
            FactoryGirl.build(:five_star_review, active: true, school: school, question:question, user: user, created: '2011-01-01'),
            FactoryGirl.build(:five_star_review, active: false, school: school, question:question, user: user, created: '2012-01-01'),
          ]
          reviews.each do
          |review| review.moderated = true
            review.save
          end
          flag_builder = Review::ReviewFlagBuilder.new(reviews[1])
          flag_builder.reasons << 'auto-flagged' 
          flag_builder.build.save
          reviews
        end
        it 'should not publish the most recent inactive non-flagged review' do
          user.verify_email!
          user.save
          subject.publish_reviews!
          existing_reviews.each(&:reload)
          expect(existing_reviews[0]).to be_inactive
          expect(existing_reviews[1]).to be_active
          expect(existing_reviews[2]).to be_inactive
        end
      end


    end
  end
end
