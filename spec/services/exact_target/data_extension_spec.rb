require 'spec_helper'

describe ExactTarget::DataExtension do
  describe ".upsert" do
    context "with a grade-by-grade subscription" do
      let(:object) { build(:student_grade_level) }

      it "should forward call with appropriate arguments" do
        expect(ExactTarget::DataExtension::Rest).to receive(:perform_call).with(:upsert_gbg, object)
        ExactTarget::DataExtension.upsert(object)
      end
    end

    context "with a newsletter subscription" do
      let(:object) { build(:subscription) }

      it "should forward call with appropriate arguments" do
        expect(ExactTarget::DataExtension::Rest).to receive(:perform_call).with(:upsert_subscription, object)
        ExactTarget::DataExtension.upsert(object)
      end
    end

    context "with a school subscription" do
      let(:object) { build(:school_user) }

      it "should forward call with appropriate arguments" do
        expect(ExactTarget::DataExtension::Rest).to receive(:perform_call).with(:upsert_school_signup, object)
        ExactTarget::DataExtension.upsert(object)
      end
    end

    context "with a school" do
      let(:object) { build(:school) }

      it "should forward call with appropriate arguments" do
        expect(ExactTarget::DataExtension::Rest).to receive(:perform_call).with(:upsert_school, object)
        ExactTarget::DataExtension.upsert(object)
      end
    end

    context "with an arbitrary object" do
      let(:object) { build(:district) }

      it "should raise ArgumentError" do
        expect { ExactTarget::DataExtension.upsert(object) }.to \
          raise_error(ArgumentError, "District does not have a matching ExactTarget DataExtension")
      end
    end
  end

  describe ".delete" do
    context "with a grade-by-grade subscription" do
      let(:object) { build(:student_grade_level) }

      it "should forward call with appropriate arguments" do
        key = ExactTarget::DataExtension::EXTENSIONS_TO_KEYS['gbg_subscriptions']
        expect(ExactTarget::DataExtension::Soap).to receive(:perform_call).with(:delete, key, object)
        ExactTarget::DataExtension.delete(object)
      end
    end

    context "with a newsletter subscription" do
      let(:object) { build(:subscription) }

      it "should forward call with appropriate arguments" do
        key = ExactTarget::DataExtension::EXTENSIONS_TO_KEYS['subscription_list']
        expect(ExactTarget::DataExtension::Soap).to receive(:perform_call).with(:delete, key, object)
        ExactTarget::DataExtension.delete(object)
      end
    end

    context "with a school subscription" do
      let(:object) { build(:school_user) }

      it "should forward call with appropriate arguments" do
        key = ExactTarget::DataExtension::EXTENSIONS_TO_KEYS['school_sign_up']
        expect(ExactTarget::DataExtension::Soap).to receive(:perform_call).with(:delete, key, object)
        ExactTarget::DataExtension.delete(object)
      end
    end

    context "with a school" do
      let(:object) { build(:school) }

      it "should forward call with appropriate arguments" do
        key = ExactTarget::DataExtension::EXTENSIONS_TO_KEYS['gs_school']
        expect(ExactTarget::DataExtension::Soap).to receive(:perform_call).with(:delete, key, object)
        ExactTarget::DataExtension.delete(object)
      end
    end

    context "with an arbitrary object" do
      let(:object) { build(:district) }

      it "should raise ArgumentError" do
        expect { ExactTarget::DataExtension.upsert(object) }.to \
          raise_error(ArgumentError, "District does not have a matching ExactTarget DataExtension")
      end
    end
  end
end