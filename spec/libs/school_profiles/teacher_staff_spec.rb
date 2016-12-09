require "spec_helper"

describe SchoolProfiles::TeachersStaff do
  let(:school) { double("school") }
  let(:school_cache_data_reader) { double("school_cache_data_reader") }
  subject(:teacher_staff) do
    SchoolProfiles::TeachersStaff.new(school_cache_data_reader)
  end

  describe '#data_values' do
    before do
      allow(school_cache_data_reader).to receive(:school).and_return(school)
      allow(school).to receive(:state).and_return(:ca)
      allow(school).to receive(:id).and_return(1)
    end

    let (:sample_data) do
      {
          'Ratio of teacher salary to total number of teachers' => [
              {
                  'school_value' => 1600,
                  'state_value' => 2000
              }
          ],
          'Percentage of full time teachers who are certified' => [
              {
                  'school_value' => 60,
                  'state_value' => 80,
              }
          ],
          'Percentage of teachers with less than three years experience' => [
              {
                  'school_value' => 60,
                  'state_value' => 80,
              }
          ]
      }
    end

    it 'should return chosen data types if data present' do
      expect(school_cache_data_reader).to receive(:gsdata_data) do
        sample_data
      end.exactly(2).times
      expect(subject.data_type_hashes.size).to eq(3)
      data_points = subject.data_values.find {|item| item.label == 'Percentage of full time teachers who are certified' }
      puts data_points.inspect
      expect(data_points).to be_present
      expect(data_points.score).to eq(60)
      expect(data_points.state_average.value).to eq(80)
    end

    it 'should return chosen data types in configured order' do
      expect(school_cache_data_reader).to receive(:gsdata_data) do
        sample_data
      end.exactly(1).times
      ordered_data_types = subject.included_data_types
      data_value_labels = subject.data_values.map(&:label)
      expect(ordered_data_types & data_value_labels).to eq(data_value_labels)
    end

    it 'should return empty array if no data' do
      expect(school_cache_data_reader).to receive(:gsdata_data).once
      expect(subject.data_type_hashes).to be_empty
    end
  end

  describe '#included_data_types' do
    it 'should return configured data types in correct order' do
      config = [
          { :data_key => 'a' }, { :data_key => 'b' }, { :data_key => 'c' }
      ].shuffle
      stub_const('SchoolProfiles::TeachersStaff::GSDATA_CACHE_ACCESSORS', config)
      expect(subject.included_data_types).to eq(config.map { |o| o[:data_key] } )
    end
  end
end
