require 'spec_helper'

describe HeldSchool do

  describe ".active_hold?" do
    it 'returns true if an active hold exists' do
      school = build_stubbed(:school)
      create(:held_school, school_id: school.id, state: school.state, active: 1)
      expect(HeldSchool.active_hold?(school)).to be_truthy
    end

    it 'returns false if an active hold does not exist' do
      school = build_stubbed(:school)
      expect(HeldSchool.active_hold?(school)).to be_falsey
    end
  end

end
