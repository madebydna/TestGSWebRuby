require 'spec_helper'
require_relative 'examples/model_with_active_field'

describe Review do
  it { is_expected.to be_a(Review) }
  it_behaves_like 'model with active field'

  after do
    clean_dbs :gs_schooldb
  end
  let(:review) { FactoryGirl.build(:review) }
  let(:school) { FactoryGirl.build(:school) }
  let(:user) { FactoryGirl.build(:user) }
  # create reported review

  let(:no_bad_language) { AlertWord::AlertWordSearchResult.new([],[]) }
  let(:alert_words) { AlertWord::AlertWordSearchResult.new(%w(alert_word_1 alert_word_2), []) }
  let(:really_bad_words) { AlertWord::AlertWordSearchResult.new([], %w(really_bad_word_1 really_bad_word_2)) }
  let(:alert_and_really_bad_words) { AlertWord::AlertWordSearchResult.new([ 'alert_word_1'], ['really_bad_word_1' ]) }


  it 'should have a calculate_and_set_status method' do
    pending("This will wait for spring 271")
    expect(subject).to respond_to :calculate_and_set_status
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

  it 'should NOT be valid if user is a student and school is not a high school' do
    pending("Get this to pass once there is a role table created")
    review.user = user
    review.who = 'student'
    review.school = school
    school.level_code = 'e,m'
    expect(review).to_not be_valid
  end

  it 'should be valid if user is a student and school is a high school' do
    pending("get this to pass once there is a role table created")
    review.user = user
    review.who = 'student'
    review.school = school
    school.level_code = 'm,h'
    expect(review).to be_valid
  end

  it 'should require an ip address' do
    pending ("Pending in case review gets ip address added")
    review.ip = nil
    expect(review).to_not be_valid
    review.ip = '123.123.123.123'
    expect(review).to be_valid
  end

  describe '#build_reported_review' do
    it "should return a reported review object with correct attributes" do
    reported_review = subject.build_reported_review('bad words','auto-flagged')
    expect(reported_review).to be_a(ReportedReview)
    expect(reported_review.comment).to eq('bad words')
    expect(reported_review.reason).to eq('auto-flagged')
    end
  end


  describe '#auto_moderate' do
    before do
      subject.school = school
    end

    it 'should not report a review with no bad language' do
      expect(AlertWord).to receive(:search).and_return(no_bad_language)
      expect(subject).to_not receive(:build_reported_review)
      subject.auto_moderate
    end

    it 'should save a reported review' do
      expect(AlertWord).to receive(:search).and_return(alert_words)
      expect(subject).to receive(:build_reported_review)
      subject.auto_moderate
    end

    it 'should send the correct comment and reason' do
      expect(AlertWord).to receive(:search).and_return(alert_words)
      expect(subject).to receive(:build_reported_review).with('Review contained warning words (alert_word_1,alert_word_2)', 'auto-flagged')
      subject.auto_moderate

      expect(AlertWord).to receive(:search).and_return(really_bad_words)
      expect(subject).to receive(:build_reported_review).with('Review contained really bad words (really_bad_word_1,really_bad_word_2)', 'auto-flagged')
      subject.auto_moderate

      expect(AlertWord).to receive(:search).and_return(alert_and_really_bad_words)
      expect(subject).to receive(:build_reported_review).with('Review contained warning words (alert_word_1) and really bad words (really_bad_word_1)', 'auto-flagged')
      subject.auto_moderate
    end

    it 'should report reviews for Delaware public schools' do
      school.state = 'DE'
      school.type = 'public'
      expect(AlertWord).to receive(:search).and_return(no_bad_language)
      expect(subject).to receive(:build_reported_review).with('Review is for GreatSchools Delaware school.', 'auto-flagged')
      subject.auto_moderate
    end

    it 'should report reviews for Delaware charter schools' do
      school.state = 'DE'
      school.type = 'charter'
      expect(AlertWord).to receive(:search).and_return(no_bad_language)
      expect(subject).to receive(:build_reported_review).with('Review is for GreatSchools Delaware school.', 'auto-flagged')
      subject.auto_moderate
    end

    it 'should not report reviews for Delaware private schools' do
      school.state = 'DE'
      school.type = 'private'
      expect(AlertWord).to receive(:search).and_return(no_bad_language)
      expect(subject).to_not receive(:build_reported_review)
      subject.auto_moderate
    end

    it 'should not report reviews for New York public schools' do
      school.state = 'NY'
      school.type = 'public'
      expect(AlertWord).to receive(:search).and_return(no_bad_language)
      expect(subject).to_not receive(:build_reported_review)
      subject.auto_moderate
    end

    it 'should not report reviews for New York charter schools' do
      school.state = 'NY'
      school.type = 'charter'
      expect(AlertWord).to receive(:search).and_return(no_bad_language)
      expect(subject).to_not receive(:build_reported_review)
      subject.auto_moderate
    end
  end

  describe '#calculate_and_set_status' do
    let(:new_user) { FactoryGirl.build(:new_user) }

    before do
      pending("this will wait for next sprint of with moderation")
      subject.school = school
      allow(AlertWord).to receive(:search).and_return(no_bad_language)
    end

    # There was a time when all reviews were automatically flagged for moderation
    # by adding another before_save filter that was called after #calculate_and_set_status
    # This tests that the auto moderation was removed correctly
    it 'should be unchanged after object called' do
      pending "Update to new role staus in model"
      registered_user = FactoryGirl.build(:verified_user)
      subject.who = 'parent'
      subject.user = new_user
      subject.calculate_and_set_status
      allow(subject).to receive(:valid?).and_return(true)
      expect{ subject.save }.to_not change{ subject.status }
    end

    it 'should check for banned IP' do
      pending("get this to work")
      subject.who = 'parent'
      subject.user = user
      allow(BannedIp).to receive(:banned_ips).and_return(['123.123.123.123'])

      subject.ip = '123.123.123.123'
      subject.calculate_and_set_status
      expect(subject).to be_unpublished

      subject.ip = '1.1.1.1'
      subject.calculate_and_set_status
      expect(subject).to_not be_unpublished
    end

    context 'when reviews are not per-moderated' do
      context 'with new user, parent' do
        before do
          subject.who = 'parent'
          subject.user = new_user
        end

        after do
          expect(subject).to be_provisional
        end

        context 'non-held school' do
          before do
            allow(subject.school).to receive(:held?).and_return(false)
          end

          it 'should have a status of pp' do
            subject.calculate_and_set_status
            expect(subject).to be_provisional_published
          end

          it 'should be unpublished if user is student' do
            subject.who = 'student'
            subject.calculate_and_set_status
            expect(subject).to be_unpublished
          end

          it 'should not be affected by alert words' do
            allow(AlertWord).to receive(:search).and_return(alert_words)
            subject.calculate_and_set_status
            expect(subject).to be_provisional_published
          end

          it 'status should be set to disabled if there are really bad words' do
            allow(AlertWord).to receive(:search).and_return(really_bad_words)
            subject.calculate_and_set_status
            expect(subject).to be_disabled
          end
        end

        context 'held school' do
          before do
            allow(subject.school).to receive(:held?).and_return(true)
          end

          it 'should have a held status' do
            subject.calculate_and_set_status
            expect(subject).to be_held
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

        after do
          expect(subject).to_not be_provisional
        end

        context 'non-held school' do
          before do
            allow(subject.school).to receive(:held?).and_return(false)
          end

          it 'should be published when user is a parent' do
            subject.who = 'parent'
            subject.calculate_and_set_status
            expect(subject).to be_published
          end

          it 'should be published when user is a principal' do
            subject.who = 'principal'
            subject.calculate_and_set_status
            expect(subject).to be_published
          end

          it 'should be unpublished if user is student' do
            subject.who = 'student'
            subject.calculate_and_set_status
            expect(subject).to be_unpublished
          end
        end

        context 'held school' do
          before do
            allow(subject.school).to receive(:held?).and_return(true)
          end

          it 'should have a held status' do
            subject.calculate_and_set_status
            expect(subject).to be_held
          end
        end
      end
    end

    context 'when reviews are pre-moderated' do
      let(:fake_property_class) { Class.new }
      before do
        stub_const('PropertyConfig', fake_property_class)
        allow(fake_property_class).to receive(:force_review_moderation?)
                                      .and_return(true)
      end
      context 'with new user, parent' do
        before do
          subject.who = 'parent'
          subject.user = new_user
        end

        after do
          expect(subject).to be_provisional
        end

        context 'non-held school' do
          before do
            allow(subject.school).to receive(:held?).and_return(false)
          end

          %w[parent principal student].each do |who|
            it "should be unpublished when user is a #{who}" do
              subject.who = who
              subject.calculate_and_set_status
              expect(subject).to be_unpublished
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

        after do
          expect(subject).to_not be_provisional
        end

        context 'non-held school' do
          before do
            allow(subject.school).to receive(:held?).and_return(false)
          end

          %w[parent principal student].each do |who|
            it "should be unpublished when user is a #{who}" do
              subject.who = who
              subject.calculate_and_set_status
              expect(subject).to be_unpublished
            end
          end
        end
      end
    end
  end

  describe '#send_thank_you_email_if_published' do
    let(:school_rating) { FactoryGirl.create(:review, active: false) }
    before do
      allow(school_rating).to receive(:calculate_and_set_active) {}
    end

    it 'Tells ThankYouForReviewEmail to send an email' do
      expect(ThankYouForReviewEmail).to receive(:deliver_to_user)
      school_rating.activate
      school_rating.save
    end

    it 'Only sends an email when status is active' do
      expect(ThankYouForReviewEmail).to_not receive(:deliver_to_user)
      school_rating.deactivate
      school_rating.save
    end

    it 'Sends only one email when review is saved multiple times' do
      expect(ThankYouForReviewEmail).to receive(:deliver_to_user).once
      school_rating.activate
      school_rating.save
      school_rating.comment = school_rating.comment + ' foo'
      school_rating.save
      school_rating.comment = school_rating.comment + ' bar'
      school_rating.save
    end

    it 'Sends two emails if review is published, disabled, published again' do
      expect(ThankYouForReviewEmail).to receive(:deliver_to_user).twice
      school_rating.activate
      school_rating.save
      school_rating.deactivate
      school_rating.save
      school_rating.activate
      school_rating.save
    end
  end

end