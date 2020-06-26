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
          MetricsCaching::Value.from_hash({
            'data_type' => 'Ratio of teacher salary to total number of teachers',
            'school_value' => 1600,
            'state_average' => 2000
          })
        ].extend(MetricsCaching::Value::CollectionMethods),
        'Percentage of full time teachers who are certified' => [
          MetricsCaching::Value.from_hash({
            'data_type' => 'Percentage of full time teachers who are certified',
            'school_value' => 60,
            'state_average' => 80,
          })
        ].extend(MetricsCaching::Value::CollectionMethods),
        'Percentage of teachers with less than three years experience' => [
          MetricsCaching::Value.from_hash({
            'data_type' => 'Percentage of teachers with less than three years experience',
            'school_value' => 60,
            'state_average' => 80,
          })
        ].extend(MetricsCaching::Value::CollectionMethods)
      }
    end

    it 'should return chosen data types if data present' do
      expect(school_cache_data_reader).to receive(:decorated_metrics_datas) do
        sample_data
      end.at_least(:once)
      sample_data.keys.each do |data_type|
        expect(subject).to receive(:data_label).with(data_type).and_return(data_type).at_least(:once)
      end
      expect(subject.data_values.size).to eq(3)
      data_points = subject.data_values.find {|item| item.label == 'Percentage of full time teachers who are certified' }
      expect(data_points).to be_present
      expect(data_points.score).to eq(60)
      expect(data_points.state_average.value).to eq(80)
    end

    it 'should return chosen data types in configured order' do
      expect(school_cache_data_reader).to receive(:decorated_metrics_datas) do
        sample_data
      end.exactly(1).times
      sample_data.keys.each do |data_type|
        expect(subject).to receive(:data_label).with(data_type).and_return(data_type).at_least(:once)
      end
      ordered_data_types = subject.included_data_types
      data_value_labels = subject.data_values.map(&:label)
      expect(ordered_data_types & data_value_labels).to eq(data_value_labels)
    end

    it 'should return empty array if no data' do
      expect(school_cache_data_reader).to receive(:decorated_metrics_datas).once
      expect(subject.data_values_by_data_type).to be_empty
    end
  end

  describe '#included_data_types' do
    it 'should return configured data types in correct order' do
      config = [
        { :data_key => 'a' }, { :data_key => 'b' }, { :data_key => 'c' }
      ].shuffle
      stub_const('SchoolProfiles::TeachersStaff::METRICS_CACHE_ACCESSORS', config)
      expect(subject.included_data_types).to eq(config.map { |o| o[:data_key] } )
    end
  end
end
