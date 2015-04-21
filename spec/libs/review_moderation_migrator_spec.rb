require 'spec_helper'
# require '../script/review_moderation_migrator'

describe ReviewModerationMigrator::SchoolRatingReviewKey do
  before { pending 'TODO: fix these'; fail }
  describe '.build' do
    # subject { ReviewModerationMigrator::ReviewNotes.new("2014-04-10") }
    let!(:review_mapping) {FactoryGirl.create(:review_mapping)}
    let!(:review_mapping_not_school_rating) {FactoryGirl.create(:review_mapping, review_id: 5, original_id: 2, table_origin: 'topical_school_review')}
    it 'should build hash mapping original school_rating_id to new review_id' do
      expect(ReviewModerationMigrator::SchoolRatingReviewKey.build).to eq({1=>2})
    end
  end
end
#
describe ReviewModerationMigrator::SchoolNotes do
  before { pending 'TODO: fix these'; fail }

  subject {ReviewModerationMigrator::SchoolNotes.new("2014-04-10")}
  after(:each) { clean_models :gs_schooldb, SchoolNote, HeldSchool }
  it 'should have the method to run the migration' do
    expect(subject).to respond_to(:run!)
  end

  describe '#truncate_school_notes' do
    context 'when there are already school notes in database' do
      before do
        FactoryGirl.create(:school_note)
      end

      it 'should respond to truncate_school_notes' do
        expect(subject).to respond_to(:truncate_school_notes)
      end

      it 'should truncate table if there is existing data' do
        pending('need to figure out how to truncate table')
        expect(SchoolNote.count).to eq(1)
        expect(SchoolNote.last.id).to eq(1)
        expect { subject.truncate_school_notes }.to change { SchoolNote.count }.by(-1)
        FactoryGirl.create(:school_note)
        expect(SchoolNote.count).to eq(1)
        expect(SchoolNote.last.id).to eq(1)
      end
    end
  end

  describe '#build_school_note' do
    let(:held_school) {FactoryGirl.build(:held_school)}
    it 'should create a new school_note with a held_school object' do
      expect(subject.build_school_note(held_school)).to be_a(SchoolNote)
      expect(subject.build_school_note(held_school).valid?).to eq(true)

    end
  end

  describe '#migrate' do
    context 'when there are no school notes in the database' do
      before do
        FactoryGirl.create(:held_school, created: "2014-04-09")
      end
      it 'should migrate all data in held_schools to school_notes' do
        expect(SchoolNote.count).to eq(0)
        expect(HeldSchool.count).to eq(1)
        expect { subject.migrate }.to change { SchoolNote.count }.by(1)
        expect(HeldSchool.first.school_id).to eq(SchoolNote.first.school_id)
        expect(HeldSchool.first.state).to eq(SchoolNote.first.state)
        expect(HeldSchool.first.notes).to eq(SchoolNote.first.notes)
        expect(HeldSchool.first.created).to eq(SchoolNote.first.created)
      end
    end
  end
end

describe ReviewModerationMigrator::ReviewNotes do

  after(:each) { clean_models :gs_schooldb, ReviewNote, ReviewNotesMigrationLog, ReviewMapping }
  after(:each) { clean_models :surveys, SchoolRating }

  describe '#initialize' do
    subject { ReviewModerationMigrator::ReviewNotes.new("2014-04-10") }
    it "sets a date to a dateTime object" do
      expect(subject.date).to be_a(Time)
      expect(subject.date).to eq(Time.parse('2014-04-10'))
    end
    it 'sets review_key to a hash' do
      # expect(subject).to receive(:build_school_rating_to_review_id_key).and_return({})
      expect(subject.review_key).to be_a(Hash)
    end

  end

  describe '#migrate' do

    context 'with 3 school_ratings with notes: 2 before and 1 after date; 1 school_rating before date without notes' do
      subject { ReviewModerationMigrator::ReviewNotes.new("2014-04-10") }
      let!(:school_rating_before_date_1) { FactoryGirl.create(:school_rating, posted: Time.parse("2014-04-09"), note: "blah") }
      let!(:school_rating_before_date_2) { FactoryGirl.create(:school_rating, posted: Time.parse("2014-04-09"), note: "blah") }
      let!(:school_rating_after_date_1) { FactoryGirl.create(:school_rating, posted: Time.parse("2014-04-10"), note: "blah") }
      let!(:school_rating_no_note) { FactoryGirl.create(:school_rating, posted: Time.parse("2014-04-09")) }
      context 'with no review_notes already created' do
        it 'should return create two new review notes' do
          allow(subject).to receive(:get_review_id).and_return(10)
          expect { subject.migrate }.to change { ReviewNote.count }.by(2)
        end
      end
      context 'with one school_note already created' do
        it 'should return create one new review note' do
          allow(subject).to receive(:get_migrated_school_rating_ids).and_return(school_rating_before_date_1.id)
          allow(subject).to receive(:get_review_id).and_return(10)
          expect { subject.migrate }.to change { ReviewNote.count }.by(1)
        end
      end
    end
  end
  describe '#build_review_note' do
    subject { ReviewModerationMigrator::ReviewNotes.new("2014-04-10") }
    context 'with a complete school_rating' do
      let(:school_rating1) { FactoryGirl.build(:school_rating, id: 10, posted: Time.parse("2014-04-09"), note: "blah") }
      it "should create a review_note with a school_rating object" do
        allow(subject).to receive(:get_review_id).with(10).and_return(2)
        expect { subject.build_review_note(school_rating1) }.to change { ReviewNote.count }.by(1)
      end
      it 'should call the log_migrated_school_rating' do
        pending("how to get this work?")
        allow(subject).to receive(:get_review_id).with(10).and_return(2)
        expect(subject.build_review_note(school_rating1)).to receive(:log_migrated_school_rating)
      end
    end
  end

  describe '#log_migrated_school_rating' do
    subject { ReviewModerationMigrator::ReviewNotes.new("2014-04-10") }
    it 'should create new review notes migration log' do
      expect { subject.log_migrated_school_rating(1, 2) }.to change { ReviewNotesMigrationLog.count }.by(1)
    end
  end

  describe '#get_review_id' do

    subject { ReviewModerationMigrator::ReviewNotes.new("2014-04-10") }
    it 'should return value from key to hash' do
      allow(subject).to receive(:review_key).and_return('4')
      subject.instance_variable_set(:@review_key, {'2'=>'4'})
      expect(subject.get_review_id('2')).to eq('4')
    end
  end

end

describe 'ReviewsModerationMigrator:ReviewFlags' do

    after(:each) { clean_models :gs_schooldb, ReviewFlag, ReviewNotesMigrationLog, ReviewMapping }
    after(:each) { clean_models :surveys, SchoolRating }
    after(:each) { clean_models :community, ReportedEntity }
    subject {ReviewModerationMigrator::ReviewFlags.new("2014-04-10")}

    describe '#initialize' do
      it 'sets a date' do
        expect(subject.date).to eq(Time.parse("2014-04-10"))
      end
      it 'sets a school_rating_key to a hash' do
        allow(subject).to receive(:school_rating_review_id_key).and_return({})
        expect(subject.review_key).to be_a(Hash)
      end
    end

    describe '#build_review_flag' do
      let(:reported_entity) { FactoryGirl.create(:old_reported_review) }
      it 'should create a new review_flag with a reported_entity_object' do
        allow(subject).to receive(:get_review_id).and_return(10)
        allow(subject).to receive(:get_reason).and_return('user-reported')
        expect { subject.build_review_flag(reported_entity) }.to change { ReviewFlag.count }.by(1)
      end

      it 'should call the log_migrated_reported_entity method' do
        pending ('ask sasmon how to get this to work')
        allow(subject).to receive(:get_review_id).and_return(10)
        allow(subject).to receive(:get_reason).and_return('user-reported')
        expect(subject.build_review_note(school_rating1)).to receive(:log_migrated_school_rating)
      end
    end

    describe '#get_reason' do
      context 'with a user-reported entity' do
        let(:reported_entity) { FactoryGirl.create(:old_reported_review) }
        it 'should return user-flagged' do
          allow(subject).to receive(:is_user_reported?).with(reported_entity).and_return(true)
          expect(subject.get_reason(reported_entity)).to eq('user-reported')
        end
      end
      context 'with reported entity autoflagged for bad language' do
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1) }
        it 'should return bad-language' do
          allow(subject).to receive(:is_bad_language?).with(reported_entity).and_return(true)
          expect(subject.get_reason(reported_entity)).to eq('bad-language')
        end
      end
      context 'with reported entity autoflagged for held-school' do
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1) }
        it 'should return held-school' do
          allow(subject).to receive(:is_bad_language?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_held_school?).with(reported_entity).and_return(true)
          expect(subject.get_reason(reported_entity)).to eq('held-school')
        end
      end
      context 'with reported entity autoflagged for student' do
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1) }
        it 'should return student' do
          allow(subject).to receive(:is_bad_language?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_held_school?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_student?).with(reported_entity).and_return(true)
          expect(subject.get_reason(reported_entity)).to eq('student')
        end
      end
      context 'with reported entity autoflagged for local-school' do
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1) }
        it 'should return local-school' do
          allow(subject).to receive(:is_bad_language?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_held_school?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_student?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_local_school?).with(reported_entity).and_return(true)
          expect(subject.get_reason(reported_entity)).to eq('local-school')
        end
      end
      context 'with reported entity autoflagged for banned-ip' do
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1) }
        it 'should return banned-ip' do
          pending ('need help to confirm if possible')
          allow(subject).to receive(:is_bad_language?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_held_school?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_student?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_local_school?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_banned_ip?).with(reported_entity).and_return(true)
          expect(subject.get_reason(reported_entity)).to eq('banned-ip')
        end
      end
      context 'with reported entity autoflagged for force-flagged' do
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1) }
        it 'should return force-flagged' do
          pending ('need help to confirm if possible')
          allow(subject).to receive(:is_bad_language?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_held_school?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_student?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_local_school?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_banned_ip?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_force_flagged?).with(reported_entity).and_return(true)
          expect(subject.get_reason(reported_entity)).to eq('force-flagged')
        end
      end
    end

  describe '#is_user_reported?' do
    context 'with user flagged reported entity' do
        let(:reported_entity) { FactoryGirl.create(:old_reported_review) }
        it 'should return true' do
          expect(subject.is_user_reported?(reported_entity)).to be(true)
        end
    end
    context 'with auto flagged reported entity' do
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1) }
        it 'should return true' do
          expect(subject.is_user_reported?(reported_entity)).to be(false)
        end
    end
  end

    describe '#is_bad_words?' do
      context 'with warning words' do
        bad_word_comment_text = ' djfkdfjdkfjkdfj warning words kdjfkdf'
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1, reason: bad_word_comment_text ) }
        it 'should return true' do
          pending ('unclear if warning words should get bad words reason')
          reported_entity.school_rating.status ='d'
          expect(subject.is_bad_language?(reported_entity)).to be(true)
        end
      end
      context 'with bad words' do
        let(:school_rating) do
          rating = FactoryGirl.build(:school_rating)
          rating.moderated = true
          rating.status = 'd'
          rating.save
          rating
        end
        bad_word_comment_text = ' djfkdfjdkfjkdfj really bad words kdjfkdf'
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1, reason: bad_word_comment_text, school_rating: school_rating) }
        it 'should return true' do
          # reported_entity.school_rating.status ='d'
          # reported_entity.school_rating.save
          expect(subject.is_bad_language?(reported_entity)).to be(true)
        end
      end
      context 'with no bad words' do
        no_bad_word_comment_text = ' djfkdfjdkfjkdfj dfjd words kdjfkdf'
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1, reason: no_bad_word_comment_text) }
        it 'should return false' do
          reported_entity.school_rating.status ='pp'
          expect(subject.is_bad_language?(reported_entity)).to be(false)
        end
      end
    end

    describe '#is_held_school?' do
      context 'with held school' do
        let(:school_rating) do
          rating = FactoryGirl.build(:school_rating)
          rating.moderated = true
          rating.status = 'ph'
          rating.save
          rating
        end
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1, school_rating: school_rating) }
        it 'should return true' do
          expect(subject.is_held_school?(reported_entity)).to be(true)
        end
      end
      context 'with no held school' do
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1) }
        it 'should return false' do
          expect(subject.is_held_school?(reported_entity)).to be(false)
        end
      end
    end

    describe '#is_student?' do
      context 'with student' do
        let(:school_rating) do
          rating = FactoryGirl.build(:school_rating)
          rating.moderated = true
          rating.who = 'student'
          rating.status = 'pu'
          rating.save
          rating
        end
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1, school_rating: school_rating) }
        # let(:school_rating) { FactoryGirl.create(:school_rating, who: 'student') }
        it 'should return true' do
          expect(subject.is_student?(reported_entity)).to be(true)
        end
      end
      context 'with it not a student' do
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1) }
        let(:school_rating) { FactoryGirl.create(:school_rating, who: 'other') }
        it 'should return true' do
          expect(subject.is_student?(reported_entity)).to be(false)
        end
      end
    end

    describe '#is_local_school?' do
      context 'with local_school' do
        local_school_text = 'Review is for GreatSchools Delaware school.'
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1, reason: local_school_text) }
        it 'should return true' do
          expect(subject.is_local_school?(reported_entity)).to be(true)
        end
      end
      context 'with it not a local_school' do
        local_school_text = 'djfkd kjfkdj dkfjdk jdkfjdf'
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1, reason: local_school_text) }
        it 'should return true' do
          expect(subject.is_local_school?(reported_entity)).to be(false)
        end
      end
    end
    describe '#is_banned_ip?' do
      context 'with banned_ip' do
        let(:school_rating) do
          rating = FactoryGirl.build(:school_rating)
          rating.moderated = true
          rating.who = 'student'
          rating.ip = 'banned-ip'
          rating.status = 'u'
          rating.save
          rating
        end
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1, school_rating: school_rating) }
        it 'should return true' do
          pending('Unclear how to get to work')
          allow(BannedIp).to receive(:is_banned?).with('banned-ip').and_return(true)
          expect(subject.is_banned_ip?(reported_entity)).to be(true)
        end
      end
      context 'with it not a banned_ip' do
        let(:school_rating) do
          rating = FactoryGirl.build(:school_rating)
          rating.moderated = true
          rating.who = 'student'
          rating.ip = 'not-banned-ip'
          rating.status = 'u'
          rating.save
          rating
        end
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1, school_rating: school_rating) }
        it 'should return false' do
          pending('Unclear how to get to work')
          allow(BannedIp).to receive(:is_banned?).with('not-banned-ip').and_return(false)
          expect(subject.is_banned_ip?(reported_entity)).to be(false)
        end
      end
    end
    describe '#is_forced_flagged?' do
      context 'with forced_flagged' do
        let(:school_rating) do
          rating = FactoryGirl.build(:school_rating)
          rating.moderated = true
          rating.who = 'other'
          rating.status = 'u'
          rating.save
          rating
        end
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1, school_rating: school_rating) }
        # let(:school_rating) { FactoryGirl.create(:school_rating, status: 'u', who: 'other') }
        it 'should return true' do
          pending('Unclear how to get to work')
          # allow(BannedIp).to receive(:is_banned?).with('not_banned-ip').and_return(false)
          allow(subject).to receive(:is_student?).with(reported_entity).and_return(false)
          allow(subject).to receive(:is_banned_ip?).with(reported_entity).and_return(false)
          expect(subject.is_force_flagged?(reported_entity)).to be(true)
        end
      end
      context 'with it not a forced_flagged' do
        let(:school_rating) do
          rating = FactoryGirl.build(:school_rating)
          rating.who = 'student'
          rating.status = 'u'
          rating.save
          rating
        end
        let(:reported_entity) { FactoryGirl.create(:old_reported_review, reporter_id: -1, school_rating: school_rating) }
        it 'should return false' do
          pending('Unclear how to get to work')
          allow(subject).to receive(:is_student?).with(reported_entity).and_return(true)
          allow(subject).to receive(:is_banned_ip?).with(reported_entity).and_return(false)
          expect(subject.is_force_flagged?(reported_entity)).to be(false)
        end
      end
    end

    describe '#get_review_id' do
      # subject { ReviewModerationMigrator::ReviewNotes.new("2014-04-10") }
      it 'should return value from key to hash' do
        # allow(subject).to receive(:review_key).and_return('4')
        subject.instance_variable_set(:@review_key, {'2' => '4'})
        expect(subject.get_review_id('2')).to eq('4')
      end
    end


    describe '#migrate' do

      context 'with 3 reported_entities: 2 before and 1 after date;' do
        subject { ReviewModerationMigrator::ReviewFlags.new("2014-04-10") }
        let!(:reported_entity_before_date_1) { FactoryGirl.create(:old_reported_review, created: Time.parse("2014-04-09")) }
        let!(:reported_entity_before_date_2) { FactoryGirl.create(:old_reported_review, created: Time.parse("2014-04-09")) }
        let!(:reported_entity_after_date_1) { FactoryGirl.create(:old_reported_review, created: Time.parse("2014-04-10")) }
        # let!(:school_rating_no_note) { FactoryGirl.create(:school_rating, posted: Time.parse("2014-04-09")) }
        context 'with no reported_entities already created' do
          it 'should return create two new review notes' do
            allow(subject).to receive(:get_migrated_school_rating_ids).and_return([-1])
            allow(subject).to receive(:get_review_id).and_return(10)
            expect { subject.migrate }.to change { ReviewFlag.count }.by(2)
          end
        end
        context 'with one reported_entity already created' do
          it 'should return create one new review note' do
            allow(subject).to receive(:get_migrated_school_rating_ids).and_return([reported_entity_before_date_1.id])
            allow(subject).to receive(:get_review_id).and_return(10)
            expect { subject.migrate }.to change { ReviewFlag.count }.by(1)
          end
        end
      end
    end

end
