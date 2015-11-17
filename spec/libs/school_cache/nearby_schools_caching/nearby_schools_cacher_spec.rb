require 'spec_helper'

describe NearbySchoolsCaching::NearbySchoolsCacher do
  let(:decorator) { NearbySchoolsCaching::QueryResultDecorator }
  let(:nearby_schools_cacher) do
    NearbySchoolsCaching::NearbySchoolsCacher.new(school)
  end

  describe '#build_hash_for_cache' do

    [
      NearbySchoolsCaching::Lists::ClosestSchools
    ].each do |list|
      context "for #{list}" do
        let(:list) { list }

        let(:school) { FactoryGirl.build(:alameda_high_school) }
        let(:level) { '9-12' }
        let(:image_hash) { 'Iamveryprettyimage' }
        let(:schools) do
          school_1 = FactoryGirl.build(:alameda_high_school, id: 1)
          allow(school_1).to receive(:great_schools_rating).and_return('8')

          school_2 = FactoryGirl.build(:bay_farm_elementary_school, id: 2)
          allow(school_2).to receive(:great_schools_rating)
          allow_any_instance_of(decorator).to receive(:school_media).and_return(image_hash)
          allow_any_instance_of(decorator).to receive(:process_level).and_return(level)
          [school_1, school_2]
        end
        let(:expected) do
          {
            list::NAME => [
              {
                id: 1,
                name: "Alameda High School",
                city: "Alameda",
                state: "CA",
                gs_rating: "8",
                type: "Public district",
                level: level,
                school_media: image_hash,
              },

              {
                id: 2,
                name: "Bay Farm Elementary School",
                city: "Alameda",
                state: "CA",
                gs_rating: "nr",
                type: "Public district",
                level: level,
                school_media: image_hash,
              }
            ]
          }
        end

        it 'should build the correct structure' do
          allow(list).to receive(:schools).and_return(schools)
          expect(nearby_schools_cacher.build_hash_for_cache).to eq(expected)
        end
      end
    end
  end
end
