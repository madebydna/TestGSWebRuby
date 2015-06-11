require 'spec_helper'
require_relative 'examples/model_with_active_field'
require_relative 'examples/model_with_school_association'

describe Review do
  it { is_expected.to be_a(Review) }
  it_behaves_like 'model with active field'
  it_behaves_like 'model with school association'

  after do
    clean_dbs :gs_schooldb
  end
  let(:review) { FactoryGirl.build(:review) }
  let(:school) { FactoryGirl.build(:school) }
  let(:user) { FactoryGirl.build(:user) }
  # create review flag

  let(:no_bad_language) { AlertWord::AlertWordSearchResult.new([],[]) }
  let(:alert_words) { AlertWord::AlertWordSearchResult.new(%w(alert_word_1 alert_word_2), []) }
  let(:really_bad_words) { AlertWord::AlertWordSearchResult.new([], %w(really_bad_word_1 really_bad_word_2)) }
  let(:alert_and_really_bad_words) { AlertWord::AlertWordSearchResult.new([ 'alert_word_1'], ['really_bad_word_1' ]) }


  it 'should have a calculate_and_set_active method' do
    expect(subject).to respond_to :calculate_and_set_active
  end

  it 'should have a combination of attributes that are valid' do
    expect(review).to be_valid
  end

  it 'should be valid with no comment' do
    review.comment = ''
    expect(review).to be_valid
  end

  it 'should require at least 15 words if it is not empty' do
    review.comment = '1 2 3 4 5 6 7 8 9 10 11 12 13 14'
    expect(review).to_not be_valid
    review.comment = '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15'
    expect(review).to be_valid
  end

  it 'should only allow up to 2400 characters' do
    review.comment = '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15'.ljust 2400, '_'
    expect(review).to be_valid
    review.comment = '1 2 3 4 5 6 7 8 9 10 11 12 13 14 15'.ljust 2401, '_'
    expect(review).to_not be_valid
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
    review.state = 'CA'
    expect(review).to be_valid
  end

  it 'should validate the state\'s format' do
    review.state = 'blah'
    expect(review).to_not be_valid
    review.state = 'CA'
    expect(review).to be_valid
  end

  it 'should require a user' do
    review.user = nil
    expect(review).to_not be_valid
    review.user = user
    expect(review).to be_valid
  end

  it 'should require an ip address' do
    pending ("TODO: Pending in case review gets ip address added")
    review.ip = nil
    expect(review).to_not be_valid
    review.ip = '123.123.123.123'
    expect(review).to be_valid
  end

  describe Review::ReviewFlagBuilder do
    describe '#build_review_flag' do
      subject do
        Review::ReviewFlagBuilder.new(review)
      end
      it "should return a ReviewFlag object with correct attributes" do
        review_flag = subject.send(:build_review_flag, 'bad words','auto-flagged')
        expect(review_flag).to be_a(ReviewFlag)
        expect(review_flag.comment).to eq('bad words')
        expect(review_flag.reason).to eq('auto-flagged')
      end
    end

    describe '#build' do
      subject do
        Review::ReviewFlagBuilder.new(review)
      end
      before do
        review.school = school
        review.user = user
      end

      it 'should not flag a review with no bad language' do
        expect(AlertWord).to receive(:search).and_return(no_bad_language)
        expect(subject).to_not receive(:build_review_flag)
        subject.auto_moderate.build
      end

      it 'should save a flagged review' do
        expect(AlertWord).to receive(:search).and_return(alert_words)
        expect(subject).to receive(:build_review_flag)
        subject.auto_moderate.build
      end

      context 'with alert words' do
        before do
          expect(AlertWord).to receive(:search).and_return(alert_words)
        end
        it 'should send the correct comment and reason' do
          expect(subject).to receive(:build_review_flag).with('Review contained warning words (alert_word_1,alert_word_2)', [:'bad-language'])
          subject.auto_moderate.build
        end
      end

      context 'with really bad words' do
        before do
          expect(AlertWord).to receive(:search).and_return(really_bad_words)
        end
        it 'should send the correct comment and reason' do
          expect(subject).to receive(:build_review_flag).with('Review contained really bad words (really_bad_word_1,really_bad_word_2)', [:'bad-language'])
          subject.auto_moderate.build
        end
      end

      context 'with alert words and really bad bad words' do
        before do
          expect(AlertWord).to receive(:search).and_return(alert_and_really_bad_words)
        end
        it 'should send the correct comment and reason' do
          expect(subject).to receive(:build_review_flag).with('Review contained warning words (alert_word_1) and really bad words (really_bad_word_1)', [:'bad-language'])
          subject.auto_moderate.build
        end
      end

      it 'should flag reviews for Delaware public schools' do
        school.state = 'DE'
        school.type = 'public'
        expect(AlertWord).to receive(:search).and_return(no_bad_language)
        expect(subject).to receive(:build_review_flag).with('Review is for GreatSchools Delaware school.', [:'local-school'])
        subject.auto_moderate.build
      end

      context 'when reviews are pre-moderated' do
        before do
          stub_const('PropertyConfig', double(:'force_review_moderation?' => true))
        end

        it 'should flag reviews that are pre-moderated' do
          expect(AlertWord).to receive(:search).and_return(no_bad_language)
          expect(subject).to receive(:build_review_flag).with(be_nil, [:'force-flagged'])
          subject.auto_moderate.build
        end
      end

      context 'when school is held' do
        before { allow(school).to receive(:held?).and_return(true) }
        it 'should flag reviews for held schools' do
          expect(AlertWord).to receive(:search).and_return(no_bad_language)
          expect(subject).to receive(:build_review_flag).with(be_nil, [:'held-school'])
          subject.auto_moderate.build
        end
      end

      context 'when user is a student' do
        let(:school_user) { FactoryGirl.build(:student_school_user) }
        before { allow(review).to receive(:school_user).and_return(school_user) }
        context 'with comment in review' do
          before { allow(review).to receive(:comment).and_return(' lorem ' * 15) }
          it 'should flag reviews for students' do
            expect(AlertWord).to receive(:search).and_return(no_bad_language)
            expect(subject).to receive(:build_review_flag).with(nil,[:'student'])
            subject.auto_moderate.build
          end
        end
        context 'without comment in review' do
          before { allow(review).to receive(:comment).and_return('') }
          it 'should not flag reviews for students' do
            expect(AlertWord).to receive(:search).and_return(no_bad_language)
            expect(subject).to_not receive(:build_review_flag)
            subject.auto_moderate.build
          end
        end
      end

      context 'when user is a principal' do
        let(:school_user) { FactoryGirl.build(:principal_school_user) }
        before do
          allow(review).to receive(:school_user).and_return(school_user)
          expect(AlertWord).to receive(:search).and_return(no_bad_language)
        end
        context 'when principal is osp verified' do
          before do
            allow(school_user).to receive(:approved_osp_user?).and_return(true)
          end
          it 'should not flag review' do
            expect(subject).to_not receive(:build_review_flag)
            subject.auto_moderate.build
          end
        end
        context 'when principal is not osp verified' do
          before do
            allow(school_user).to receive(:approved_osp_user?).and_return(false)
          end
          it 'should not flag review' do
            expect(subject).to receive(:build_review_flag).with(
                                 'User self reported as principal but is not an approved OSP user',
                                 [:'auto-flagged']
                               )
            subject.auto_moderate.build
          end
        end
      end

      it 'should flag reviews for Delaware charter schools' do
        school.state = 'DE'
        school.type = 'charter'
        expect(AlertWord).to receive(:search).and_return(no_bad_language)
        expect(subject).to receive(:build_review_flag).with('Review is for GreatSchools Delaware school.', [:'local-school'])
        subject.auto_moderate.build
      end

      it 'should not flag reviews for Delaware private schools' do
        school.state = 'DE'
        school.type = 'private'
        expect(AlertWord).to receive(:search).and_return(no_bad_language)
        expect(subject).to_not receive(:build_review_flag)
        subject.auto_moderate.build
      end

      it 'should not flag reviews for New York public schools' do
        school.state = 'NY'
        school.type = 'public'
        expect(AlertWord).to receive(:search).and_return(no_bad_language)
        expect(subject).to_not receive(:build_review_flag)
        subject.auto_moderate.build
      end

      it 'should not flag reviews for New York charter schools' do
        school.state = 'NY'
        school.type = 'charter'
        expect(AlertWord).to receive(:search).and_return(no_bad_language)
        expect(subject).to_not receive(:build_review_flag)
        subject.auto_moderate.build
      end
    end
  end

  describe '#calculate_and_set_active' do
    let(:new_user) { FactoryGirl.build(:new_user) }

    before do
      subject.school = school
      allow(AlertWord).to receive(:search).and_return(no_bad_language)
    end

    it 'should check for banned IP' do
      pending('TODO: do we need an ip method on review')
      fail
      allow(subject).to receive(:user_type).and_return('parent')
      subject.user = user
      allow(BannedIp).to receive(:banned_ips).and_return(['123.123.123.123'])

      subject.ip = '123.123.123.123'
      subject.calculate_and_set_active
      expect(subject).to be_inactive

      subject.ip = '1.1.1.1'
      subject.calculate_and_set_active
      expect(subject).to_not be_inactive
    end

    context 'when reviews are not per-moderated' do
      context 'with new parent user' do
        let(:parent_school_user) { FactoryGirl.build(:parent_school_user) }
        before do
          allow(subject).to receive(:school_user).and_return(parent_school_user)
          subject.user = new_user
        end

        context 'non-held school' do
          before do
            allow(subject.school).to receive(:held?).and_return(false)
          end
        end

        it 'review should be inactive since user is provisional' do
          subject.calculate_and_set_active
          expect(subject).to be_inactive
        end
      end

      context 'with registered user' do
        let(:registered_user) { FactoryGirl.build(:verified_user) }
        let(:principal_school_user) { FactoryGirl.build(:principal_school_user) }
        let(:student_school_user) { FactoryGirl.build(:student_school_user) }
        let(:parent_school_user) { FactoryGirl.build(:parent_school_user) }

        before do
          subject.school = school
          subject.user = registered_user
          allow(AlertWord).to receive(:search).and_return(no_bad_language)
          allow(subject).to receive(:school_user).and_return(parent_school_user)
        end

        context 'non-held school' do
          before do
            allow(subject.school).to receive(:held?).and_return(false)
          end

          it 'should be active when user is a parent' do
            allow(subject).to receive(:school_user).and_return(parent_school_user)
            subject.calculate_and_set_active
            expect(subject).to be_active
          end

          it 'should be inactive if user is student and review has comment' do
            subject.comment = ' foo ' * 15
            allow(subject).to receive(:school_user).and_return(student_school_user)
            subject.calculate_and_set_active
            expect(subject).to be_inactive
          end

          it 'should be active if user is student and review has no comment' do
            allow(subject).to receive(:school_user).and_return(student_school_user)
            subject.calculate_and_set_active
            expect(subject).to be_active
          end

          it 'should be inactive if user is a principal and not approved' do
            allow(principal_school_user).to receive(:approved_osp_user?).and_return(false)
            allow(subject).to receive(:school_user).and_return(principal_school_user)
            subject.calculate_and_set_active
            expect(subject).to be_inactive
          end

          it 'should be active if user is a principal and is approved' do
            allow(principal_school_user).to receive(:approved_osp_user?).and_return(true)
            allow(subject).to receive(:school_user).and_return(principal_school_user)
            subject.calculate_and_set_active
            expect(subject).to be_active
          end

          it 'should not be affected by alert words' do
            allow(AlertWord).to receive(:search).and_return(alert_words)
            subject.calculate_and_set_active
            expect(subject).to be_active
          end

          it 'status should be set to inactive if there are really bad words' do
            subject.comment = ' foo ' * 15
            allow(AlertWord).to receive(:search).and_return(really_bad_words)
            subject.calculate_and_set_active
            expect(subject).to be_inactive
          end
        end

        context 'held school' do
          before do
            allow(subject.school).to receive(:held?).and_return(true)
          end

          it 'should have a held status' do
            subject.calculate_and_set_active
            expect(subject).to be_inactive
          end
        end
      end
    end

    context 'when reviews are pre-moderated' do
      before do
        stub_const('PropertyConfig', double(:'force_review_moderation?' => true))
      end
      context 'with new user, parent' do
        before do
          allow(subject).to receive(:user_type).and_return('parent')
          subject.user = new_user
        end

        after do
          expect(subject).to be_inactive
        end

        context 'non-held school' do
          before do
            allow(subject.school).to receive(:held?).and_return(false)
          end

          %w[parent principal student].each do |who|
            it "should be unpublished when user is a #{who}" do
              allow(subject).to receive(:user_type).and_return(who)
              subject.calculate_and_set_active
              expect(subject).to be_inactive
            end
          end
        end
      end

      context 'with registered user' do
        let(:registered_user) { FactoryGirl.build(:verified_user) }

        before do
          subject.school = school
          subject.user = registered_user
          allow(AlertWord).to receive(:search).and_return(no_bad_language)
        end

        context 'non-held school' do
          before do
            allow(subject.school).to receive(:held?).and_return(false)
          end

          %w[parent principal student].each do |who|
            it "should be unpublished when user is a #{who}" do
              allow(subject).to receive(:user_type).and_return(who)
              subject.calculate_and_set_active
              expect(subject).to be_inactive
            end
          end
        end
      end
    end
  end

  describe '#send_thank_you_email_if_published' do
    let(:review) { FactoryGirl.create(:review, active: true) }
    let(:user) { FactoryGirl.create(:user) }
    before { allow(review).to receive(:user).and_return(user) }
    context 'if review active' do
      it 'should send email' do
        expect(user).to receive(:send_thank_you_email_for_school)
        review.send_thank_you_email_if_published
      end
    end

    context 'if review not active' do
      let(:review) { FactoryGirl.create(:review, active: false) }
      it 'should not send email' do
        expect(user).to_not receive(:send_thank_you_email_for_school)
        review.send_thank_you_email_if_published
      end
    end
  end

  describe '#uniqueness' do
    let(:user) { FactoryGirl.create(:verified_user) }
    let(:school) do
      FactoryGirl.create(:alameda_high_school)
    end
    let(:question) do
      FactoryGirl.create(:overall_rating_question)
    end
    after do
      clean_models School
      clean_dbs :gs_schooldb
    end

    it 'should prevent multiple active reviews for the same user / school / question' do
      review = FactoryGirl.create(:five_star_review, active: false, school: school, question:question, user: user)
      review.moderated = true
      review.activate
      review.save!

      expect do
        review = FactoryGirl.create(:five_star_review, active: false, school: school, question:question, user: user)
        review.moderated = true
        review.activate
        review.save!
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: You have already submitted a review for this topic.')
    end

    it 'should not prevent multiple inactive reviews for the same user / school / question' do
      3.times do
        expect do
          review = FactoryGirl.create(:five_star_review, active: false, school: school, question:question, user: user)
          review.moderated = false
          review.deactivate
          review.save!
        end.to_not raise_error
      end
    end
  end

  describe '#comment' do
    after do
      clean_models Review
    end
    context 'when review has no comment' do
      let(:review) { FactoryGirl.create(:review, comment: nil) }
      subject { review.comment }
      it { is_expected.to be_nil }
    end
  end

  describe '#answer_as_int' do
    after do
      clean_models Review
    end
    context 'with five star review answer integer value saved as string' do
      let(:five_star_review_value_4_str) { FactoryGirl.build(:five_star_review, answer_value: '4') }
      subject { five_star_review_value_4_str }
      it 'should return answer value as int' do
        expect(subject.answer_as_int).to be_a(Integer)
      end
      it 'should return the correct answer value as integer' do
        expect(subject.answer_as_int).to eq(4)
      end
    end
    context 'with string review answer string value that is not an integer' do
      let(:review_with_string_answer) { FactoryGirl.build(:teacher_effectiveness_review)}
      subject { review_with_string_answer}
      it 'should return the string answer value as nil' do
        expect(subject.answer_as_int).to eq(nil)
      end
    end
  end
end