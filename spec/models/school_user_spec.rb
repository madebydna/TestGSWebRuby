require 'spec_helper'

shared_context 'when user type has value' do |value|
  before { subject.user_type = value }
end


describe SchoolUser do
  let(:user) { FactoryGirl.build(:verified_user) }
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:school_user) { FactoryGirl.build(:school_user, user: user, school: school, user_type: nil) }
  subject { school_user }
  after do
    clean_dbs(:gs_schooldb)
  end

  describe '#user_type' do
    before do
      expect(subject).to_not receive(:approved_osp_user?)
    end
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

  describe '#first_unanswered_topic' do
    let(:topics) { FactoryGirl.build_list(:review_topic, 4) }
    let(:reviews) do
      [
        double(topic: topics.first),
        double(topic: topics.last)
      ]
    end
    subject { school_user.first_unanswered_topic }

    it 'should get reviews for the given school' do
      expect(user).to receive(:reviews_for_school).with(school: school).and_return(reviews)
      subject
    end

    it 'should return the first unanswered topic' do
      allow(user).to receive(:reviews_for_school).and_return(reviews)
      allow(ReviewTopic).to receive(:active).and_return(topics)
      expect(subject).to eq(topics[1])
    end
  end

  describe "#find_active_review_by_question_id" do
    let(:user) { FactoryGirl.create(:verified_user) }
    let(:school) { FactoryGirl.create(:a_high_school) }
    let(:reviews) { FactoryGirl.create_list(:review, 5) }
    let(:review_questions) { FactoryGirl.create_list(:review_question, 5) }
    before do
      (0..4).to_a.each do |n|
        reviews[n].question = review_questions[n]
        reviews[n].user = user
        reviews[n].school = school
        reviews[n].save
      end
    end
    after do
      clean_models User, Review, ReviewQuestion, ReviewTopic
      clean_models :ca, School
    end
    it 'should return only the review for current user, given school, matching review question' do
      expect(subject.find_active_review_by_question_id(review_questions[3].id))
        .to eq(reviews[3])
    end
  end

  describe '.make_from_esp_membership' do
    context 'when school user already exists for esp membership' do
      it 'does not overwrite existing school_user' do
        esp_membership = double(
          member_id: 1,
          state: 'ca',
          school_id: 1
        )
        school_user = double(
          new_record?: false
        )
        expect(SchoolUser).to receive(:find_by).and_return(school_user)
        expect(school_user).to_not receive(:'user_type=')
        expect(school_user).to_not receive(:save!)
        SchoolUser.make_from_esp_membership(esp_membership)
      end
    end
    context 'when school user does not exist for esp membership' do
      it 'does not set user type or save the school user' do
        esp_membership = double(
          member_id: 1,
          state: 'ca',
          school_id: 1
        )
        school_user = double(
          new_record?: true
        )
        expect(SchoolUser).to receive(:find_by).and_return(nil)
        expect(SchoolUser).to receive(:new).and_return(school_user)
        expect(school_user).to receive(:'user_type=').with('principal')
        expect(school_user).to receive(:save!)
        SchoolUser.make_from_esp_membership(esp_membership)
      end

    end

  end
end
