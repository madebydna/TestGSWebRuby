require "spec_helper"

describe SchoolUserDigest do

  describe "#create" do
    context "with user and school" do
      it "should return unique encrypted key for user and school" do
        school = build(:school)
        user = build(:user, id: 234234)
        user2 = build(:user, id: 2344344344234)
        first_id = SchoolUserDigest.new(user, school).create
        matching_id = SchoolUserDigest.new(user, school).create
        mismatching_id = SchoolUserDigest.new(user2, school).create

        expect(first_id).to eq(matching_id)
        expect(first_id).to_not eq(user.id)
        expect(first_id).to_not eq(school.id)
        expect(first_id).to be_a(String)
      end
    end

    context "missing user" do
      it "should return nil" do
        school = build(:school)
        user = nil
        result = nil
        expect(SchoolUserDigest.new(user, school).create).to eq(result)
      end
    end

    context "missing school" do
      it "should return nil" do
        school = nil
        user = build(:user)
        result = nil
        expect(SchoolUserDigest.new(user, school).create).to eq(result)
      end
    end

    context "missing both school and user" do
      it "should return nil" do
        school = nil
        user = nil
        result = nil
        expect(SchoolUserDigest.new(user, school).create).to eq(result)
      end
    end
  end
end
