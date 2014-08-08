require 'spec_helper'

describe SchoolRating do
  after do
    clean_dbs :surveys
  end

  let(:review) { FactoryGirl.build(:valid_school_rating) }
  let(:school) { FactoryGirl.build(:school) }
  let(:user) { FactoryGirl.build(:user) }

  let(:no_bad_language) { AlertWord::AlertWordSearchResult.new([],[]) }
  let(:alert_words) { AlertWord::AlertWordSearchResult.new(%w(alert_word_1 alert_word_2), []) }
  let(:really_bad_words) { AlertWord::AlertWordSearchResult.new([], %w(really_bad_word_1 really_bad_word_2)) }
  let(:alert_and_really_bad_words) { AlertWord::AlertWordSearchResult.new([ 'alert_word_1'], ['really_bad_word_1' ]) }

  it 'should have a calculate_and_set_status method' do
    expect(subject).to respond_to :calculate_and_set_status
  end

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
    review.user = user
    review.who = 'student'
    review.school = school
    school.level_code = 'e,m'
    expect(review).to_not be_valid
  end

  it 'should be valid if user is a student and school is a high school' do
    review.user = user
    review.who = 'student'
    review.school = school
    school.level_code = 'm,h'
    expect(review).to be_valid
  end

  it 'should require an ip address' do
    review.ip = nil
    expect(review).to_not be_valid
    review.ip = '123.123.123.123'
    expect(review).to be_valid
  end

  describe '#auto_report_bad_language' do

    it 'should not report a review with no bad language' do
      expect(AlertWord).to receive(:search).and_return(no_bad_language)
      expect(ReportedEntity).to_not receive(:from_review)
      subject.auto_report_bad_language
    end

    it 'should save a reported entity' do
      expect(AlertWord).to receive(:search).and_return(alert_words)
      expect(ReportedEntity).to receive(:from_review)
      subject.auto_report_bad_language
    end

    it 'should send the correct reason' do
      expect(AlertWord).to receive(:search).and_return(alert_words)
      expect(ReportedEntity).to receive(:from_review).with(subject, 'Review contained warning words (alert_word_1,alert_word_2)')
      subject.auto_report_bad_language

      expect(AlertWord).to receive(:search).and_return(really_bad_words)
      expect(ReportedEntity).to receive(:from_review).with(subject, 'Review contained really bad words (really_bad_word_1,really_bad_word_2)')
      subject.auto_report_bad_language

      expect(AlertWord).to receive(:search).and_return(alert_and_really_bad_words)
      expect(ReportedEntity).to receive(:from_review).with(subject, 'Review contained warning words (alert_word_1) and really bad words (really_bad_word_1)')
      subject.auto_report_bad_language
    end

  end

  describe '#calculate_and_set_status' do
    let(:new_user) { FactoryGirl.build(:new_user) }

    before do
      subject.school = school
      allow(AlertWord).to receive(:search).and_return(no_bad_language)
    end

    # There was a time when all reviews were automatically flagged for moderation
    # by adding another before_save filter that was called after #calculate_and_set_status
    # This tests that the auto moderation was removed correctly
    it 'should be unchanged after object called' do
      registered_user = FactoryGirl.build(:verified_user)
      subject.who = 'parent'
      subject.user = new_user
      subject.calculate_and_set_status
      allow(subject).to receive(:valid?).and_return(true)
      expect{ subject.save }.to_not change{ subject.status }
    end

    it 'should check for banned IP' do
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

  describe '#provisional' do
    it 'status pp should be provisional' do
      subject.status = 'pp'
      expect(subject).to be_provisional
    end

    it 'status p should not be provisional' do
      subject.status = 'p'
      expect(subject).to_not be_provisional
    end

    it 'status d should not be provisional' do
      subject.status = 'd'
      expect(subject).to_not be_provisional
    end

    it 'nil status should not be provisional' do
      subject.status = nil
      expect(subject).to_not be_provisional
    end
  end

  describe '#provisional_published' do
    it 'status pp should be provisional_published' do
      subject.status = 'pp'
      expect(subject).to be_provisional_published
    end

    it 'status p should be provisional_published' do
      subject.status = 'p'
      expect(subject).to_not be_provisional_published
    end

    it 'status d should not be provisional_published' do
      subject.status = 'd'
      expect(subject).to_not be_provisional_published
    end

    it 'nil status should not be provisional_publishedd' do
      subject.status = nil
      expect(subject).to_not be_provisional_published
    end
  end

  describe '#published' do
    it 'status pp should be published' do
      subject.status = 'pp'
      expect(subject).to_not be_published
    end

    it 'status p should be published' do
      subject.status = 'p'
      expect(subject).to be_published
    end
  end

  describe '#disabled' do
    it 'status pp should not be disabled' do
      subject.status = 'pp'
      expect(subject).to_not be_disabled
    end

    it 'status d should be disabled' do
      subject.status = 'd'
      expect(subject).to be_disabled
    end

    it 'nil status should not be disabled' do
      subject.status = nil
      expect(subject).to_not be_disabled
    end
  end

  describe '#unpublished' do
    it 'status pu should be unpublished' do
      subject.status = 'pu'
      expect(subject).to be_unpublished
    end

    it 'status u should be unpublished' do
      subject.status = 'u'
      expect(subject).to be_unpublished
    end

    it 'status d should not be unpublished' do
      subject.status = 'd'
      expect(subject).to_not be_unpublished
    end
  end

  describe '#set_process_date_if_published' do
    it 'sets process date when published' do
      subject.status = 'p'
      subject.set_processed_date_if_published
      expect(subject.process_date).to_not be_nil
    end

    it 'doesnt set process date if not published' do
      subject.status = 'pp'
      subject.set_processed_date_if_published
      expect(subject.process_date).to be_nil
    end
  end

  describe '#overall' do
    let(:school_rating) { FactoryGirl.build(:school_rating) }
    before(:each) do
      school_rating.quality = 'decline'
      school_rating.p_overall = 'decline'
    end

    it 'should return the overall rating for non-preschools' do
      school_rating.quality = '5'
      expect(school_rating.overall).to eq '5'
      school_rating.quality = 'decline'
      expect(school_rating.overall).to eq 'decline'
    end

    it 'should return the overall rating for preschools' do
      school_rating.p_overall = '5'
      expect(school_rating.overall).to eq '5'
      school_rating.p_overall = 'decline'
      expect(school_rating.overall).to eq 'decline'
    end
  end

  describe '#send_thank_you_email_if_published' do
    let(:school_rating) { FactoryGirl.build(:school_rating, status: 'p') }
    before do
      allow(school_rating).to receive(:calculate_and_set_status) {}
    end

    it 'Tells ThankYouForReviewEmail to send an email' do
      expect(ThankYouForReviewEmail).to receive(:deliver_to_user)
      school_rating.save
    end

    it 'Only sends an email when status is published' do
      expect(ThankYouForReviewEmail).to_not receive(:deliver_to_user)
      %w[pp ph pd pu h d u].each do |status|
        school_rating.status = status
        school_rating.save
      end
      school_rating.save
    end

    it 'Sends only one email when review is saved multiple times' do
      expect(ThankYouForReviewEmail).to receive(:deliver_to_user).once
      school_rating.save
      school_rating.comments = school_rating.comments + ' blah'
      school_rating.save
    end

    it 'Sends two emails if review is published, disabled, published again' do
      expect(ThankYouForReviewEmail).to receive(:deliver_to_user).twice
      school_rating.save
      school_rating.status = 'd'
      school_rating.save
      school_rating.status = 'p'
      school_rating.save
    end
  end

end
