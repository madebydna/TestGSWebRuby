require 'spec_helper'

def school_info_assertion
  expect(subject[:school_info]).to eq(
    {
      gradeLevel: school_level,
      name: school_name,
      type: school_type.titleize
    }
  )
end
describe SchoolDataHash do

  let(:school_name)  { 'Alpha High' }
  let(:school_type)  { 'public'     }
  let(:school_level) { '9-13'       }
  let(:school) { FactoryGirl.create(:school, name: school_name, type: school_type) }
  let(:characteristics) do
    {
      'characteristics' => {
        '4-year high school graduation rate' => [
          {
            "year" => 2013,
            "original_breakdown" => "Asian",
            "school_value" => 98.32,
            "state_average" => 84.47,
            "performance_level" => "above_average"
          },
        ],
        'Percent of students who meet UC/CSU entrance requirements' => [
          {
            "year" => 2013,
            "original_breakdown" => "Asian",
            "school_value" => 98.32,
            "state_average" => 84.47,
            "performance_level" => "above_average"
          },
        ]
      }
    }
  end

  before do
    allow(school).to receive(:process_level).and_return(school_level)
  end

  after do
    clean_models :ca, School
  end

  describe '#initialize' do
    context 'with no options' do

      subject do
        allow(school).to receive(:cache_data).and_return(nil)
        SchoolDataHash.new(school, {}).data_hash
      end

      it 'should add the basic school info' do
        school_info_assertion
      end

      it 'should not have other keys' do
        expect(subject.keys).to eq([:school_info])
      end
    end

    value_hash = {
      value: 98,
      state_average: 84,
      performance_level: "above_average"
    }
    {'asian' => value_hash, 'fake' => {}}.each do |breakdown, expected_value|
      context "with #{breakdown} set for subgroup" do
        [
          ['a_through_g'],
          ['graduation_rate'],
          ['a_through_g', 'graduation_rate']
        ].each do |data_sets|
          context "with #{data_sets.join(' & ')} configured" do
            before do
              allow(school).to receive(:cache_data).and_return(characteristics)
            end

            subject do
              SchoolDataHash.new(
                school,
                data_sets: data_sets,
                sub_group_to_return: breakdown
              ).data_hash
            end

            it 'should have the basic school info' do
              school_info_assertion
            end

            data_sets.each do |data_set|
              it "should have #{data_set} data" do
                expect(subject[data_set.to_sym]).to eq(expected_value)
              end
            end
          end
        end
      end
    end
  end
end
