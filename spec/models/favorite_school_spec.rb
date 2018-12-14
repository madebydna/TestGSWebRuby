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

  describe '#school' do
    it 'should ask School class to find the school' do
      favorite_school = FactoryGirl.build(
        :favorite_school,
        state: 'ca',
        school_id: 1
      )
      expect(School).to receive(:find_by_state_and_id)
        .with('ca', 1).and_return nil
      favorite_school.school
    end
  end

  describe '#methods to persists favorite schools for users' do
    before(:each) do
      clean_dbs :gs_schooldb
    end
    let(:cristo_hs) { FactoryGirl.build(:cristo_rey_new_york_high_school) }
    let(:head_start) { FactoryGirl.build(:washington_dc_ps_head_start) }
    let(:new_user) { FactoryGirl.build(:verified_user, id: 3) }

    it "should create a favorite school instance" do
      [cristo_hs, head_start].each do |school|
        saved_school = FavoriteSchool.create_saved_school_instance(school, new_user.id)
        expect([saved_school.state, saved_school.school_id]).to eq([school.state, school.id])
      end
    end

    it 'should return a list of saved schools if given an user id' do
      [cristo_hs, head_start].each do |school|
        saved_school = FavoriteSchool.create_saved_school_instance(school, new_user.id)
        saved_school.save
      end
      expect(FavoriteSchool.saved_school_list(new_user.id)).to eq([[cristo_hs.state&.downcase, cristo_hs.id], [head_start.state&.downcase, head_start.id]])
      expect(FavoriteSchool.count).to eq(2) 
    end
  end

end