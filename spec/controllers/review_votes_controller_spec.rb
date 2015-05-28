require 'spec_helper'

describe ReviewVotesController do

  describe '#create' do
    let!(:review) do
      FactoryGirl.create(:five_star_review)
    end
    let(:user) { review.user }
    after do
      clean_dbs :gs_schooldb
    end
    context 'when logged in' do
      before do
        controller.instance_variable_set(:@current_user, user)
      end

      it 'should save a new review vote' do
        xhr :post, :create, id: review.id
        vote = ReviewVote.active.where(review_id: review.id).to_a
        expect(vote).to be_present
        expect(vote.size).to eq(1)
        expect(vote.first).to be_active
      end

      context 'when user already voted on review' do
        let!(:vote) { FactoryGirl.create(:review_vote, review: review, user: user) }
        it 'should not save another vote' do
          xhr :post, :create, id: review.id
          vote = ReviewVote.where(review_id: review.id).to_a
          expect(vote).to be_present
          expect(vote.size).to eq(1)
          expect(vote.first).to be_active
        end
      end

      context 'when user has a previously deactivated vote' do
        let!(:vote) { FactoryGirl.create(:review_vote, review: review, user: user, active: false) }
        it 'should reactivate existing vote' do
          xhr :post, :create, id: review.id
          vote = ReviewVote.where(review_id: review.id).to_a
          expect(vote).to be_present
          expect(vote.size).to eq(1)
          expect(vote.first).to be_active
        end
      end
    end
  end

  describe '#destroy' do
    let!(:review) do
      FactoryGirl.create(:five_star_review)
    end
    let(:user) { review.user }
    after do
      clean_dbs :gs_schooldb
    end
    context 'when logged in' do
      before do
        controller.instance_variable_set(:@current_user, user)
      end

      it 'should not error if vote doesn\'t exist' do
        xhr :post, :destroy, id: review.id
        vote = ReviewVote.where(review_id: review.id).to_a
        expect(vote).to_not be_present
      end

      context 'when user has voted on review' do
        let!(:vote) { FactoryGirl.create(:review_vote, review: review, user: user) }
        it 'should deactivate the vote' do
          xhr :post, :destroy, id: review.id
          vote = ReviewVote.where(review_id: review.id).to_a
          expect(vote).to be_present
          expect(vote.size).to eq(1)
          expect(vote.first).to be_inactive
        end
      end

      context 'when user has a previously deactivated vote' do
        let!(:vote) { FactoryGirl.create(:review_vote, review: review, user: user, active: false) }
        it 'should leave the previous vote deactivated' do
          xhr :post, :destroy, id: review.id
          vote = ReviewVote.where(review_id: review.id).to_a
          expect(vote).to be_present
          expect(vote.size).to eq(1)
          expect(vote.first).to be_inactive
        end
      end
    end
  end

end