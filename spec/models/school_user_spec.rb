require 'spec_helper'

shared_context 'when user type has value' do |value|
  before { subject.user_type = value }
end


describe SchoolUser do
  let(:user) { FactoryGirl.build(:verified_user) }
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:school_user) { FactoryGirl.build(:school_member, user: user, school: school, user_type: nil) }
  subject { school_user }
  after do
    clean_dbs(:gs_schooldb)
  end

  describe '#user_type' do
    context 'when user is not esp member' do
      {
        nil => :unknown,
        'unknown' => :unknown,
        'parent' => :parent,
        'community member' => :'community member',
        'foo' => :unknown
      }.each_pair do |value_from_db, expected_value|
        with_shared_context 'when user type has value', value_from_db do
          its(:user_type) { is_expected.to eq expected_value }
        end
      end
    end
    context 'when user is an esp member' do
      before do
        allow(subject).to receive(:approved_osp_user?).and_return true
      end
      {
        nil => :principal,
        'unknown' => :principal,
        'community member' => :'community member',
        'parent' => :parent,
        'foo' => :principal
      }.each_pair do |value_from_db, expected_value|
        with_shared_context 'when user type has value', value_from_db do
          its(:user_type) { is_expected.to eq expected_value }
        end
      end
    end
  end

  describe '#approved_osp_user?' do
    let(:mock_esp_memberships) { double }
    before do
      allow(user).to receive(:esp_memberships).and_return(mock_esp_memberships)
      expect(mock_esp_memberships).to receive(:for_school).with(school).and_return school_esp_memberships
    end
    context 'when there is an approved esp membership for the user and school' do
      let(:school_esp_memberships) { [ FactoryGirl.build(:esp_membership, :with_approved_status) ] }
      it { is_expected.to be_approved_osp_user }
    end
    context 'when there is only a provisional esp membership for the user and school' do
      let(:school_esp_memberships) { [ FactoryGirl.build(:esp_membership, :with_provisional_status) ] }
      it { is_expected.to_not be_approved_osp_user }
    end
  end

  describe '#provisional_osp_user?' do
    let(:mock_esp_memberships) { double }
    before do
      allow(user).to receive(:esp_memberships).and_return(mock_esp_memberships)
      expect(mock_esp_memberships).to receive(:for_school).with(school).and_return school_esp_memberships
    end
    context 'when there is a provisional esp membership for the user and school' do
      let(:school_esp_memberships) { [ FactoryGirl.build(:esp_membership, :with_provisional_status) ] }
      it { is_expected.to be_provisional_osp_user }
    end
    context 'when there is only an approved esp membership for the user and school' do
      let(:school_esp_memberships) { [ FactoryGirl.build(:esp_membership, :with_approved_status) ] }
      it { is_expected.to_not be_provisional_osp_user }
    end
  end

  describe '#handle_saved_reviews_for_students_and_principals' do
    subject { school_user }
    context 'with student' do
      before do
        allow(subject).to receive(:student?).and_return(true)
        allow(subject).to receive(:principal?).and_return(false)
      end
      it 'should deactivate reviews with comments' do
        expect(subject).to receive(:deactivate_reviews_with_comments!)
        subject.handle_saved_reviews_for_students_and_principals
      end
    end
    context 'with principal' do
      before do
        allow(subject).to receive(:student?).and_return(false)
        allow(subject).to receive(:principal?).and_return(true)
      end
      it 'should deactivate all reviews' do
        expect(subject).to receive(:deactivate_reviews!)
        subject.handle_saved_reviews_for_students_and_principals
      end
      it 'should remove all review answers' do
        expect(subject).to receive(:remove_review_answers!)
        subject.handle_saved_reviews_for_students_and_principals
      end
    end
  end

  describe '#deactivate_reviews!' do
    subject { school_user }
    context 'with reviews with comments' do
      let(:reviews) { FactoryGirl.build_list(:review, 4) }
      before do
        allow(subject).to receive(:reviews).and_return(reviews)
      end
      after { clean_models(:gs_schooldb, Review, ReviewTopic, ReviewQuestion) }
      it 'should deactivate all reviews' do
        expect { subject.deactivate_reviews!}.to change { reviews.map(&:active) }.from(Array.new(4,true)).to(Array.new(4,false))
      end
    end

    context 'with reviews without comments' do
      let(:reviews) { FactoryGirl.build_list(:review, 4, comment: '') }
      before do
        allow(subject).to receive(:reviews).and_return(reviews)
      end
      after { clean_models(:gs_schooldb, Review, ReviewTopic, ReviewQuestion) }
      it 'should deactivate all reviews' do
        expect { subject.deactivate_reviews! }.to change { reviews.map(&:active) }.from(Array.new(4, true)).to(Array.new(4, false))
      end
    end
  end

  describe '#remove_review_answers!' do
    subject { school_user }
    let (:school) { FactoryGirl.build(:school)}
    let(:review_answers) { FactoryGirl.build_list(:review_answer, 2, value: 1) }
    let(:reviews) { FactoryGirl.build_list(:review, 2) }
    before do
      reviews.each_with_index do |review, index|
        review.answers << review_answers[index]
        review.save
      end
      allow(subject).to receive(:reviews).and_return(reviews)
    end

    it 'should remove all review answers' do
     subject.remove_review_answers!
      reviews.each do |review|
        expect(review.answers.count).to eq(0)
      end
    end
  end

  describe '#deactivate_reviews_with_comments!' do
    subject { school_user }

    context 'with review without comments' do
      let(:reviews) { FactoryGirl.build_list(:review, 2, comment: ' lorem ' * 15) }
      before do
        allow(subject).to receive(:reviews).and_return(reviews.extend ReviewScoping)
      end
      after { clean_models(:gs_schooldb, Review, ReviewTopic, ReviewQuestion)}
      it 'should deactivate both reviews' do
        expect{subject.deactivate_reviews_with_comments!}.to change {reviews.map(&:active)}.from(Array.new(2,true)).to(Array.new(2,false))
      end
    end

    context 'with review with comment' do
      let(:reviews) { FactoryGirl.build_list(:review, 2, comment: '') }
      before do
        allow(subject).to receive(:reviews).and_return(reviews.extend ReviewScoping)
      end
      after { clean_models(:gs_schooldb, Review, ReviewTopic, ReviewQuestion)}
      it 'should not deactivate review' do
        expect{subject.deactivate_reviews_with_comments!}.to_not change {reviews.map(&:active) }
        expect(reviews.map(&:active)).to eq([true, true])
      end
    end
  end

end