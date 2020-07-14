require 'spec_helper'

describe ExactTarget::DataExtension do
  describe ".upsert" do
    context "with a grade_by_grade subscription" do
      let(:object) { build(:student_grade_level) }

      it "should forward call with appropriate arguments" do
        expect(ExactTarget::DataExtension::Rest).to receive(:perform_call).with(:upsert_gbg, object)
        ExactTarget::DataExtension.upsert('grade_by_grade', object)
      end
    end

    context "with a newsletter subscription" do
      let(:object) { build(:subscription) }

      it "should forward call with appropriate arguments" do
        expect(ExactTarget::DataExtension::Rest).to receive(:perform_call).with(:upsert_subscription, object)
        ExactTarget::DataExtension.upsert('subscription', object)
      end
    end

    context "with a school subscription" do
      let(:object) { build(:school_user) }

      it "should forward call with appropriate arguments" do
        expect(ExactTarget::DataExtension::Rest).to receive(:perform_call).with(:upsert_school_signup, object)
        ExactTarget::DataExtension.upsert('school_subscription', object)
      end
    end

    context "with a school" do
      let(:object) { build(:school) }

      it "should forward call with appropriate arguments" do
        expect(ExactTarget::DataExtension::Rest).to receive(:perform_call).with(:upsert_school, object)
        ExactTarget::DataExtension.upsert('school', object)
      end
    end

    context "with an arbitrary object" do
      let(:object) { build(:district) }

      it "should raise ArgumentError" do
        expect { ExactTarget::DataExtension.upsert('district', object) }.to \
          raise_error(ArgumentError, "district does not have a matching ExactTarget DataExtension")
      end
    end
  end

  describe ".delete" do
    context "with a grade-by-grade subscription" do
      it "should forward call with appropriate arguments" do
        key = ExactTarget::DataExtension::EXTENSIONS_TO_KEYS['gbg_subscriptions']
        expect(ExactTarget::DataExtension::Soap).to receive(:perform_call).with(:delete, key, [1])
        ExactTarget::DataExtension.delete('grade_by_grade', 1)
      end
    end

    context "with a newsletter subscription" do
      it "should forward call with appropriate arguments" do
        key = ExactTarget::DataExtension::EXTENSIONS_TO_KEYS['subscription_list']
        expect(ExactTarget::DataExtension::Soap).to receive(:perform_call).with(:delete, key, [100])
        ExactTarget::DataExtension.delete('subscription', 100)
      end
    end

    context "with a school subscription" do
      it "should forward call with appropriate arguments" do
        key = ExactTarget::DataExtension::EXTENSIONS_TO_KEYS['school_sign_up']
        expect(ExactTarget::DataExtension::Soap).to receive(:perform_call).with(:delete, key, [11])
        ExactTarget::DataExtension.delete('school_subscription', 11)
      end
    end

    context "with a school" do
      it "should forward call with appropriate arguments" do
        key = ExactTarget::DataExtension::EXTENSIONS_TO_KEYS['gs_school']
        expect(ExactTarget::DataExtension::Soap).to receive(:perform_call).with(:delete, key, [23])
        ExactTarget::DataExtension.delete('school', 23)
      end
    end

    context "with an arbitrary type" do
      it "should raise ArgumentError" do
        expect { ExactTarget::DataExtension.delete('district', 123) }.to \
          raise_error(ArgumentError, "district does not have a matching ExactTarget DataExtension")
      end
    end

    context "with muliple ids to delete" do
      it "should forward call with appropriate arguments" do
        key = ExactTarget::DataExtension::EXTENSIONS_TO_KEYS['school_sign_up']
        expect(ExactTarget::DataExtension::Soap).to receive(:perform_call).with(:delete, key, [10,11,12])
        ExactTarget::DataExtension.delete('school_subscription', [10,11,12])
      end
    end
  end
end