require 'spec_helper'

def school_info_assertion
  expect(subject[:school_info]).to eq(
    {
      gradeLevel: school_level,
      name: school_name,
      type: I18n.db_t(school_type).titleize,
      city: school.city,
      state: school.state,
      url: school_url
    }
  )
end
describe SchoolDataHash do

  let(:school_name)  { 'Alpha High' }
  let(:school_type)  { 'public'     }
  let(:school_level) { '9-12'       }
  let(:school_url)   { '/california/alpha-high-city/1-alpha-high'  }
  let(:school) { FactoryGirl.create(:school, name: school_name, type: school_type, level: "9,10,11,12") }
  let(:link_helper) { Object.new }
  let(:characteristics) do
    {
      'characteristics' => {
        '4-year high school graduation rate' => [
          {
            "year" => 2013,
            "original_breakdown" => "Asian",
            "school_value_2013" => 98.32,
            "state_average_2013" => 84.47,
            "performance_level" => "above_average"
          }.symbolize_keys,
        ],
        'Percent of students who meet UC/CSU entrance requirements' => [
          {
            "year" => 2014,
            "original_breakdown" => "Asian",
            "school_value_2014" => 98.32,
            "state_average_2014" => 84.47,
            "performance_level" => "above_average"
          }.symbolize_keys,
        ]
      }
    }
  end
  let(:cachified_school) { SchoolCacheDecorator.new(school, characteristics) }

  before do
    allow(link_helper).to receive(:school_path).and_return(school_url)
  end

  after do
    clean_models :ca, School
  end

  describe '#initialize' do
    context 'with no options' do

      subject do
        SchoolDataHash.new(cachified_school, {link_helper: link_helper}).data_hash
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
      performance_level: "above_average",
      show_no_data_symbol: false
    }
    {'asian' => value_hash, 'fake' => {show_no_data_symbol: true}}.each do |breakdown, expected_value|
      context "with #{breakdown} set for subgroup" do
        [
          {'a_through_g' => 2014},
          {'graduation_rate' => 2013},
          {'a_through_g' => 2014, 'graduation_rate' => 2013}
        ].each do |data_sets_and_years|
          context "with #{data_sets_and_years} configured" do

            subject do
              SchoolDataHash.new(
                cachified_school,
                data_sets_and_years: data_sets_and_years.with_indifferent_access,
                sub_group_to_return: breakdown,
                link_helper: link_helper
              ).data_hash
            end

            it 'should have the basic school info' do
              school_info_assertion
            end

            data_sets_and_years.keys.each do |data_set|
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
