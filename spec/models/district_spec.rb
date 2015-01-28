require 'spec_helper'

describe District do

  describe '#nearby_districts' do
    it 'should sort districts by distance' do
      nearby_district_objects = [
        FactoryGirl.build(:nearby_district,
          neighbor_state: 'CA',
          neighbor_id: 2,
          distance: 3
        ),
        FactoryGirl.build(:nearby_district,
          neighbor_state: 'CA',
          neighbor_id: 1,
          distance: 5
        )
      ]

      allow(NearbyDistrict).
        to receive_message_chain(:find_by_district, :sorted_by_distance).
        and_return(nearby_district_objects)

      # These districts are not yet in ascending order by distance
      districts = [
        FactoryGirl.build(:district, id: 1),
        FactoryGirl.build(:district, id: 2)
      ]

      allow(District).to receive(:find_by_state_and_ids).
        with('CA', [2, 1]).
        and_return(districts)

      expect(subject.nearby_districts.map(&:id)).to eq([2, 1])
    end
  end

  describe '#schools_by_rating_desc' do
    it 'should sort schools by rating in descending order with NR at end' do
      schools = FactoryGirl.build_list(:school, 10)
      # Set rating to the position of the school in the list
      schools.each_with_index do |s, index|
        rating = (index == 0) ? 'NR' : index
        allow(s).to receive(:great_schools_rating).and_return(rating)
      end

      # Randomize the list of schools
      schools.shuffle!

      allow(School).to receive(:within_district).
        with(subject).
        and_return(schools)

      allow(School).to receive(:preload_school_metadata!)

      sorted_schools = subject.schools_by_rating_desc

      expect(sorted_schools.map(&:great_schools_rating)).to eq(
        [9, 8, 7, 6, 5, 4, 3, 2, 1, 'NR']
      )
    end
  end


  
end