require "spec_helper"

describe ReviewSavingMessenger do
  after do
    clean_dbs(:gs_schooldb, :ca)
  end

  describe "#run" do
    context "with a user with registered email" do
      let(:verified_user) { build(:verified_user) }
      it "should return activated message with one active review" do
        active_saved_review = build(:teacher_effectiveness_review, user: verified_user)
        inactive_saved_review = build(:homework_review, user: verified_user, active: 0)
        reviews = [active_saved_review, inactive_saved_review]
        result_hash = {
          active: true,
          message: I18n.t("actions.review.activated")
        }

        messenger = ReviewSavingMessenger.new(verified_user, reviews)
        expect(messenger.run).to eq(result_hash)
      end

      it "should return moderation message with one moderated review" do
        moderated_saved_review = create(:teacher_effectiveness_review,
                                        :flagged,
                                        active: 0,
                                        user: verified_user)
        reviews = [moderated_saved_review]
        result_hash = {
          active: false,
          message: I18n.t("actions.review.pending_moderation")
        }

        messenger = ReviewSavingMessenger.new(verified_user, reviews)
        expect(messenger.run).to eq(result_hash)
      end
      it "should return activated message with 1 moderated review & 1 active review" do
        active_saved_review = build(:teacher_effectiveness_review, user: verified_user)
        auto_moderated_review = build(:homework_review, :flagged, active: 0, user: verified_user)
        reviews = [active_saved_review, auto_moderated_review]
        result_hash = {
          active: true,
          message: I18n.t("actions.review.activated")
        }

        messenger = ReviewSavingMessenger.new(verified_user, reviews)
        expect(messenger.run).to eq(result_hash)
      end

      it "should return default message and log error with no active messages" do
        reviews = build_list(:review, 2, user: verified_user, active: 0)
        result_hash = {
          active: false,
          message: "Your reviews have not been activated"
        }

        messenger = ReviewSavingMessenger.new(verified_user, reviews)
        expect(GSLogger).to receive(:error)
        expect(messenger.run).to eq(result_hash)
      end
    end

    context "with a user with unregistered email" do
      it "should return unregistered email message" do
        unverified_user = build(:new_user)
        inactive_saved_review = build(:homework_review, user: unverified_user, active: 0)
        result_hash = {
          active: false,
          message: I18n.t("actions.review.pending_email_verification")
        }

        messenger = ReviewSavingMessenger.new(unverified_user, [inactive_saved_review])
        expect(messenger.run).to eq(result_hash)
      end
    end
  end
end
