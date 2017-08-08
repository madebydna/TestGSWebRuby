require "spec_helper"

describe SchoolUserDigest do

  describe "#create" do
    context "with user and school" do
      it "should return unique encrypted key for user and school" do
        school = build(:school)
        user = build(:user, id: 234234)
        user2 = build(:user, id: 2344344344234)
        first_id = SchoolUserDigest.new(user.id, school).create
        matching_id = SchoolUserDigest.new(user.id, school).create
        mismatching_id = SchoolUserDigest.new(user2.id, school).create

        expect(first_id).to eq(matching_id)
        expect(first_id).to_not eq(user.id)
        expect(first_id).to_not eq(school.id)
        expect(first_id).to_not eq(mismatching_id)
        expect(first_id).to be_a(String)
      end
    end

    context "missing user" do
      it "should return nil" do
        school = build(:school)
        member_id = nil
        expect(SchoolUserDigest.new(member_id, school).create).to be_nil
      end
    end

    context "missing school" do
      it "should return nil" do
        school = nil
        member_id = 5
        expect(SchoolUserDigest.new(member_id, school).create).to be_nil
      end
    end

    context "missing both school and user" do
      it "should return nil" do
        school = nil
        member_id = nil
        expect(SchoolUserDigest.new(member_id, school).create).to be_nil
      end
    end
  end
end
