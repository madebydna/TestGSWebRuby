require 'spec_helper'

describe GroupComparisonDataReader do

  subject { GroupComparisonDataReader.new(nil) }

  let(:category_data) do
    [
      FactoryGirl.build(
        :category_data,
        response_key: 'first_data_type',
        label: 'first_data_type'
      ),
      FactoryGirl.build(
        :category_data,
        response_key: 'second_data_type',
        label: 'second_data_type'
      ),
      FactoryGirl.build(
        :category_data,
        response_key: 'third_data_type',
        label: 'third_data_type'
      ),
    ]
  end
  let(:sample_data) {
    {
      [:first_data_type, nil] => [
        {
          year: 2013,
          breakdown: 'Pacific Islander different than ethnicity label',
          original_breakdown: 'Original breakdown',
          school_value: 100.0,
          state_average: 78.35,
          performance_level: 'above_average',
        }
      ],
      [:second_data_type, nil] => [
        {
          year: 2013,
          breakdown: 'Male',
          original_breakdown: 'Male',
          school_value: 90.0,
          state_average: 98.35,
          performance_level: 'average',
        }
      ],
      [:third_data_type, nil] => [
        {
          year: 2013,
          breakdown: 'Economically disadvantaged',
          original_breakdown: 'Economically disadvantaged',
          school_value: 10.0,
          state_average: 8.35,
          performance_level: 'below_average',
        }
      ],
    }
  }

  let(:all_students_test_data) {
    {
      [:first_data_type, nil] => [
        {
          year: 2013,
          breakdown: 'All students',
          original_breakdown: 'All students',
          school_value: 100.0,
          state_average: 78.35,
          performance_level: 'above_average',
        }
      ],
      [:second_data_type, nil] => [
        {
          year: 2013,
          breakdown: 'Male',
          original_breakdown: 'Male',
          school_value: 90.0,
          state_average: 98.35,
          performance_level: 'average',
        }
      ],
      [:third_data_type, nil] => [
        {
          year: 2013,
          breakdown: 'Economically disadvantaged',
          original_breakdown: 'Economically disadvantaged',
          school_value: 10.0,
          state_average: 8.35,
          performance_level: 'below_average',
        }
      ],
    }
  }

  let(:ethnicity_subtext_data) {
    {
      [:Ethnicity, nil] => [
        {
          year: 2013,
          breakdown: 'Pacific Islander',
          original_breakdown: 'Original breakdown',
          school_value: 100.0,
          state_average: 78.35,
          performance_level: 'above_average',
        },
      ],
    }
  }
  let(:types_subtext_data) {
    {
      [:Male, nil] => [
        {
          year: 2013,
          breakdown: 'All students',
          original_breakdown: 'All students',
          school_value: 90.0,
          state_average: 98.35,
          performance_level: 'average',
        }
      ],
      ['Students participating in free or reduced-price lunch program'.to_sym, nil] => [
        {
          year: 2013,
          breakdown: 'All students',
          original_breakdown: 'All students',
          school_value: 10.0,
          state_average: 8.35,
          performance_level: 'below_average',
        }
      ],
    }
  }
  let(:enrollment_subtext_data) {
    {
      [:Enrollment, nil] => [
        {
          year: 2013,
          breakdown: 'All students',
          original_breakdown: 'All students',
          school_value: 10.0,
          state_average: 8.35,
          performance_level: 'below_average',
        }
      ],
    }
  }
  let(:empty_data) {
    {
      [:"4-year high school graduation rate", nil] => [
        {
          year: 2013,
          source: "TX Education Agency",
          created: "2014-10-15T13:47:52-07:00"
        }
      ]
    }
  }

  let(:sample_label_map) { Hash[sample_data.map { |k,v| [[k.first.to_s, nil],"#{k} label"] }] }
  let(:fake_category) do
    o = Object.new
    allow(o).to receive(:keys).and_return(sample_data.keys)
    allow(o).to receive(:key_label_map).and_return(sample_label_map)
    allow(o).to receive(:parsed_json_config).and_return({}.with_indifferent_access)
    o
  end


  describe '#data_for_category' do
    context 'with valid data' do
      before do
        allow(subject).to receive(:category).and_return(fake_category)
        allow(fake_category).to receive(:category_data).and_return(category_data)
        allow(subject).to receive(:cached_data_for_category).and_return(sample_data)
        allow(subject).to receive(:modify_data!)
        allow(subject).to receive(:configure_data_type_partials!)
        allow(subject).to receive(:config_for_collection).and_return({})
      end

      it 'should create a DataDisplayCollection for each data type' do
        expect(DataDisplayCollection).to receive(:new).exactly(sample_data.keys.size).times
        subject.data_for_category(fake_category)
      end

      it "should return an array of data display collections" do
        subject.data_for_category(fake_category).each do |data_display_collection|
          expect(data_display_collection).to be_a DataDisplayCollection
        end
      end
    end

    context 'with only all students data for a data type' do
      before do
        allow(subject).to receive(:category).and_return(fake_category)
        allow(fake_category).to receive(:category_data).and_return(category_data)
        allow(subject).to receive(:cached_data_for_category).and_return(all_students_test_data)
        allow(subject).to receive(:configure_data_type_partials!)
        allow(subject).to receive(:config_for_collection).and_return({})
        allow(subject).to receive(:valid_data_display_collections?).and_return(true)
      end

      it 'should create a DataDisplayCollection for each data type' do
        expect(DataDisplayCollection).to receive(:new).exactly(sample_data.keys.size).times
        subject.data_for_category(fake_category)
      end

      it 'should remove the all students collection' do
        collections = subject.data_for_category(fake_category)
        expect(collections.map(&:title)).to eq(['second_data_type', 'third_data_type'])
      end
    end

    context 'with empty data' do
      before do
        allow(subject).to receive(:category).and_return(fake_category)
        allow(fake_category).to receive(:category_data).and_return(category_data)
        allow(subject).to receive(:cached_data_for_category).and_return(empty_data)
        allow(subject).to receive(:modify_data!)
      end

      it "should return an empty array" do
        expect(subject.data_for_category(fake_category)).to eq([])
      end
    end
  end

  describe '#get_data!' do
    context 'when config has {breakdown: \'Ethnicity\', breakdown_all: \'Enrollment\'} set' do
      before do
        allow(subject).to receive(:category).and_return(fake_category)
        allow(fake_category).to receive(:category_data).and_return(category_data)
        allow(subject).to receive(:cached_data_for_category).and_return(sample_data)
        allow(subject).to receive(:get_cache_data).with(data_type: SchoolCache::ETHNICITY).and_return(ethnicity_subtext_data)
        allow(subject).to receive(:get_cache_data).with(data_type: SchoolCache::ENROLLMENT).and_return(enrollment_subtext_data)
        all_types = Genders.all + StudentTypes.all_datatypes
        allow(subject).to receive(:get_cache_data).with(all_types.map { |t| { data_type: t } }).and_return(types_subtext_data)
        allow(subject).to receive(:category).and_return(fake_category)
        allow(subject).to receive(:config).and_return({
          breakdown: 'Ethnicity',
          breakdown_all: 'Enrollment',
          group_comparison_callbacks: [
            'add_ethnicity_callback',
            'add_enrollment_callback',
            'add_student_types_callback',
          ]
        }.with_indifferent_access)
        subject.send(:get_data!)
      end

      let(:school) { FactoryGirl.create(:school, id: 1) }

      subject { GroupComparisonDataReader.new(school) }

      after { clean_models :gs_schooldb, SchoolCache }
      after { clean_models :ca, School }

      it 'should return results with the subtext key set' do
        subject.data.values.first.each do |d|
          expect(d[:subtext]).to be_present
        end
      end

      context 'when there is corresponding Ethnicity, gender, or programs data for a data set' do
        it 'should set subtext to \'x% of population\'' do
          subject.data.values.first.each do |d|
            (expect(d[:subtext]).to include '% of population') unless d[:breakdown] == 'All students'
          end
        end
      end

      context 'when there is corresponding Enrollment data for a data set' do
        it 'should set subtext to \'number students tested\'' do
          subject.data.values.first.each do |d|
            (expect(d[:subtext]).to include 'students tested') if d[:breakdown] == 'All students'
          end
        end
      end
    end
  end

end
