require "spec_helper"

describe GsdataLoading::Update do
  describe "#new" do
    context "with valid update blob" do
      it "sbould not raise errors" do
        valid_update_blob = {
          state: "ca",
          school_id: 1
        }
        expect { GsdataLoading::Update.new(valid_update_blob) }
          .to_not raise_error
      end
    end
    context "with update blob missing state" do
      it "should raise errors" do
        invalid_update_blob = {
          blah: "ca",
          school_id: 1
        }
        err_message = "Every gsdata update must have have a state specified"
        expect { GsdataLoading::Update.new(invalid_update_blob) }
          .to raise_error(err_message)
      end
    end
    context "with update blob missing school_id" do
      it "should raise errors" do
        invalid_update_blob = {
          state: "ca",
          schol_id: 1
        }
        err_mssg = "Every gsdata update must have have a school_id specified"
        expect { GsdataLoading::Update.new(invalid_update_blob) }
          .to raise_error(err_mssg)
      end
    end
  end

  describe "#state_db" do
    it "should return correctly formatted state db name" do
      state_name = "CA"
      valid_update_blob = {
        state: state_name,
        school_id: 1
      }
      expect(GsdataLoading::Update.new(valid_update_blob).state_db)
        .to eq(state_name.downcase.to_sym)
    end
  end
end
