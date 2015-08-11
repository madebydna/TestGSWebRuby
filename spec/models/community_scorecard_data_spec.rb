require 'spec_helper'

describe CommunityScorecardData do
  shared_context 'save breakdowns' do
    let(:default_breakdown) do
      {
        '4-year high school graduation rate' => [
          {
            "year" => 2013,
            "breakdown" => "Asian",
            "school_value" => 100.0,
            "state_average" => 84.47,
            "performance_level" => "above_average"
          },
        ],
        'Percent of students who meet UC/CSU entrance requirements' => [
          {
            "year" => 2013,
            "breakdown" => "Asian",
            "school_value" => 100.0,
            "state_average" => 84.47,
            "performance_level" => "above_average"
          },
        ]
      }
    end

    before do
      school_info.each do |sd|
        FactoryGirl.create(:school, id: sd.school_id, state: sd.state)
        value = default_breakdown.deep_dup
        value.values.flatten.each { |v| v['school_value'], v['breakdown'] = sd.school_value, sd.breakdown }
        FactoryGirl.create(:school_characteristic_responses, school_id: sd.school_id, state: sd.state, value: value.to_json)
      end
    end

    before do
      allow_any_instance_of(CommunityScorecardData).to receive(:temp_school_data_service).and_return(school_info)
    end

    after do
      clean_models :gs_schooldb, SchoolCache
      clean_models :ca, School
    end

  end

  shared_context 'with a asian breakdowns saved into the database' do
    let(:school_info) do
      school_info_struct = Struct.new(:school_id, :state, :school_value, :breakdown)
      [
        school_info_struct.new(19, 'ca', 59, 'Asian'),
        school_info_struct.new(1, 'ca', 22, 'Asian'),
        school_info_struct.new(6397, 'ca', 1, 'Asian')
      ]
    end
    include_context 'save breakdowns'
  end

  shared_context 'with the graduation_rate and a_through_g data sets selected' do
    before do
      allow_any_instance_of(CommunityScorecardData).to receive(:school_data_params).and_return({
        data_sets: ['graduation_rate', 'a_through_g'],
        sub_group_filter: 'asian'
      })
    end
  end


  describe '#get_school_data' do
    with_shared_context 'with a asian breakdowns saved into the database' do
      with_shared_context 'with the graduation_rate and a_through_g data sets selected' do
        subject { CommunityScorecardData.new.get_school_data }

        it 'should return a basic set of school info' do
          subject.each do | school_data |
            [:id, :state, :level_code, :gs_rating, :grade_level].each do |key|
              expect(school_data.has_key?(key)).to be_truthy
            end
          end
        end

        it 'should return data containing graduation rate' do
          subject.each do | sd |
            expect(sd.has_key?(:graduation_rate)).to be_truthy
          end
          school_info.each_with_index do | si, i |
            expect(si.school_value).to eql(subject[i][:graduation_rate][:value])
          end
        end

        it 'should return data containing a through g info' do
          subject.each do | sd |
            expect(sd.has_key?(:a_through_g)).to be_truthy
          end
          school_info.each_with_index do | si, i |
            expect(si.school_value).to eql(subject[i][:a_through_g][:value])
          end
        end

        it 'should preserve the order of schools that solr returned' do
          school_info.each_with_index do | si, i |
            expect(si.school_id).to eql(subject[i][:id])
          end
        end
      end
    end
  end

end
