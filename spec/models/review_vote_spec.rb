require 'spec_helper'

describe ReviewVote do

  describe '.vote_count_by_id' do
    let!(:provisional_user1) { FactoryBot.create(:new_user) }
    let!(:provisional_user2) { FactoryBot.create(:new_user) }
    let!(:provisional_user3) { FactoryBot.create(:new_user) }
    let!(:verified_user1) { FactoryBot.create(:verified_user) }
    let!(:verified_user2) { FactoryBot.create(:verified_user) }
    let!(:verified_user3) { FactoryBot.create(:verified_user) }

    let!(:review1) { FactoryBot.create(:five_star_review) }
    let!(:review2) { FactoryBot.create(:five_star_review) }

    let!(:review_votes_by_verified_user) do
      [] <<
      FactoryBot.create(:review_vote, user: verified_user1, review: review1) <<
      FactoryBot.create(:review_vote, user: verified_user2, review: review1) <<
      FactoryBot.create(:review_vote, user: verified_user3, review: review1) <<
      FactoryBot.create(:review_vote, user: verified_user1, review: review2) <<
      FactoryBot.create(:review_vote, user: verified_user2, review: review2)
    end
    let!(:review_votes_by_provisional_user) do
      [] <<
      FactoryBot.create(:review_vote, user: provisional_user1, review: review1) <<
      FactoryBot.create(:review_vote, user: provisional_user2, review: review1) <<
      FactoryBot.create(:review_vote, user: provisional_user3, review: review1) <<
      FactoryBot.create(:review_vote, user: provisional_user1, review: review2) <<
      FactoryBot.create(:review_vote, user: provisional_user2, review: review2)
    end

    after do
      clean_dbs :gs_schooldb
    end

    it 'should not count votes by provisional users' do
      result = ReviewVote.vote_count_by_id([review1.id, review2.id])
      expect(result[review1.id]).to eq(3)
      expect(result[review2.id]).to eq(2)
    end

    it 'should count votes where user is null' do
      FactoryBot.create(:review_vote, user: nil, review: review1)
      FactoryBot.create(:review_vote, user: nil, review: review2)
      result = ReviewVote.vote_count_by_id([review1.id, review2.id])
      expect(result[review1.id]).to eq(4)
      expect(result[review2.id]).to eq(3)
    end
  end
end
