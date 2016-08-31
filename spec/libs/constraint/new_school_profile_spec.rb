require "spec_helper"

describe Constraint::NewSchoolProfile do

  after do
    clean_dbs(:ca)
  end
  describe "#matches?" do
    it "should return true for school with new profile flag" do
      new_profile_school_request = double()
      new_profile_school_request.stub(:parameters) do
        {state: "california", schoolId: "1"}
      end
      school_with_flag = create(:school_with_new_profile, state: "CA", id: 1)

      expect(Constraint::NewSchoolProfile.new.matches?(new_profile_school_request))
        .to eq(true)
    end

    it "should return false for school without a new profile flag" do
      school_profile_request = double()
      school_profile_request.stub(:parameters) do
        {state: "california", schoolId: "1"}
      end
      school_with_no_flag = create(:school, state: "CA", id: 1)

      expect(Constraint::NewSchoolProfile.new.matches?(school_profile_request))
        .to eq(false)
    end

    it "should return false with no school found" do
      school_profile_request = double()
      school_profile_request.stub(:parameters) do
        {state: "california", schoolId: "1"}
      end

      expect(Constraint::NewSchoolProfile.new.matches?(school_profile_request))
        .to eq(false)
    end

    it "should return true with a school with new profile flag in a two word state" do
      new_profile_school_request = double()
      new_profile_school_request.stub(:parameters) do
        {state: "new-jersey", schoolId: "1"}
      end
      school_with_flag = build(:school_with_new_profile, state: "NJ", id: 1)
      school_class= double("school_class")
      stub_const("School", school_class)
      allow(school_class).to receive(:find_by_state_and_id).with('nj', "1")
        .and_return(school_with_flag)

      expect(Constraint::NewSchoolProfile.new.matches?(new_profile_school_request))
        .to eq(true)
    end
  end
end


