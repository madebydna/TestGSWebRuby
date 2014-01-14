require 'spec_helper'

describe FavoriteSchool do

  it 'should belong to a User' do
    association = FavoriteSchool.reflect_on_association(:user)
    expect(association.macro).to eq(:belongs_to)
  end

  describe '.initialize' do

    let(:school) { FactoryGirl.build(:school) }

    it 'should set copy school id and state from provided school' do
      favorite_school = FavoriteSchool.build_for_school school
      expect(favorite_school.state).to eq(school.state)
      expect(favorite_school.school_id).to eq(school.id)
    end

    it 'should set the updated date' do
      favorite_school = FavoriteSchool.build_for_school school
      expect(favorite_school.updated).to_not be_nil
    end


  end

end