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
                  'school_value' => 1600
              }
          ],
          'Percentage of full time teachers who are certified' => [
              {
                  'school_value' => 60
              }
          ],
          'Average ACT score' => [
              {
                  'school_value' => 20
              }
          ]
      }
    end

    it 'should return chosen data types if data present' do
      pending
      # expect(school_cache_data_reader).to receive(:gsdata_data) do
      #   sample_data
      # end.exactly(2).times
      allow(school_cache_data_reader).to receive(:gsdata_data).and_return(sample_data)
      expect(subject.data_type_hashes.size).to eq(2)
      # data_points = subject.data_values.find {|item| item.label == 'Average SAT score' }
      # expect(data_points).to be_present
      # expect(data_points.score).to eq(1600)
      # expect(data_points.state_average).to eq(1400)
      # expect(data_points.range).to eq((600..2400))
    end

    it 'should return chosen data types in configured order' do
      pending
      expect(school_cache_data_reader).to receive(:gsdata_data_data) do
        sample_data
      end
      # included_data_types = subject.included_data_types
      # data_value_labels = subject.data_values.map(&:label)

      # start with full set of ordered data types, then remove items
      # that are not in the resulting data_value_labels. Expression should
      # yield an array that is in same order as data_value_labels
      # expect(included_data_types & data_value_labels).to eq(data_value_labels)
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
