require 'spec_helper'

describe SchoolRating do
  let(:review) { FactoryGirl.build(:valid_school_rating) }
  let(:school) { FactoryGirl.build(:school) }
  let(:user) { FactoryGirl.build(:user) }

  it 'should have a combination of attributes that are valid' do
    expect(review).to be_valid
  end

  it 'should require at least 15 words' do
    review.comments = ''
    expect(review).to_not be_valid
    review.comments = '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15'
    expect(review).to be_valid
  end

  it 'should treat groups of symbols as words' do
    # treating a group of symbols as a word since legacy code does so
    review.comments = '- - - - - - - - - - - - - - -'
    expect(review).to be_valid
  end

  it 'should only allow up to 1200 characters' do
    review.comments = '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15'.ljust 1200, '_'
    expect(review).to be_valid
    review.comments = '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15'.ljust 1201, '_'
    expect(review).to_not be_valid
  end

  it 'should require a status' do
    review.status = ''
    expect(review).to_not be_valid
    review.status = 'p'
    expect(review).to be_valid
  end

  it 'should require a school' do
    review.school = nil
    expect(review).to_not be_valid
    review.school = school
    expect(review).to be_valid
  end

  it 'should require a state' do
    review.state = nil
    expect(review).to_not be_valid
    review.state = 'ca'
    expect(review).to be_valid
  end

  it 'should validate the state\'s format' do
    pending
    review.state = 'blah'
    expect(review).to_not be_valid
    review.state = 'ca'
    expect(review).to be_valid
  end

  it 'should require a user' do
    review.user = nil
    expect(review).to_not be_valid
    review.user = user
    expect(review).to be_valid
  end

end
