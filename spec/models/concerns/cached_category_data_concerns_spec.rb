require 'spec_helper'

describe CachedCategoryDataConcerns do
  subject do
    class FakeClass
      include CachedCategoryDataConcerns
    end
    FakeClass.new
  end

  let(:category) { FactoryGirl.build(:category) }
  let(:data_type) { :data_type }
  let(:label) { 'label' }
  let(:translated_label) { 'translated_label' }

  before do
    allow(subject).to receive(:category).and_return(category)
  end

  after do
    clean_models :localized_profiles, Category, CategoryData
  end

  describe '#cached_data_for_category' do
    let(:math_subject_id) { 2 }
    let(:enrollment_category_data) do
      FactoryGirl.build(
        :category_data,
        response_key: 'Enrollment',
        label: label,
      )
    end
    let(:rating_category_data) do
      FactoryGirl.build(
        :category_data,
        subject_id: math_subject_id,
        response_key: 'GreatSchools Rating',
        label: label,
      )
    end
    let(:category_data) do
      [
        enrollment_category_data,
        rating_category_data,
      ]
    end
    let(:cache_data) do
      {
        Enrollment: [],
        :'GreatSchools Rating' => [ { subject: 'Math' } ],
        :'Another data type' => [],
      }
    end

    before do
      allow(subject).to receive(:all_school_cache_data).and_return(cache_data)
      allow(category).to receive(:category_data).and_return(category_data)
      allow(subject).to receive(:convert_subject_to_id).with('Math').and_return(math_subject_id)
    end

    it 'should return only data types that match category data' do
      expected_keys = [
        [:Enrollment, nil],
        [:'GreatSchools Rating', math_subject_id],
      ]
      returned_data = subject.cached_data_for_category.keys
      expect(returned_data.size).to eq(expected_keys.size)
      expected_keys.each do |expected_key|
        expect(returned_data).to include(expected_key)
      end
    end
  end

  describe '#transform_data_keys' do

    shared_examples_for 'it should make the keys [label, translated_label, subject_id] for subject_id' do |subject_id|
      subject_id_for_p = subject_id.nil? ? 'nil' : subject_id
      it "should make the keys [label, translated_label, #{subject_id_for_p}]" do
        category_data = FactoryGirl.build(
          :category_data,
          subject_id: subject_id,
          response_key: data_type.to_s,
          label: label,
        )
        cache_data = {
          [data_type, subject_id] => [
            { data: 'data would go here' }
          ]
        }
        allow(category).to receive(:category_data).and_return([category_data])
        category_data_school_cache_map = subject.get_category_data_school_cache_map
        allow(subject).to receive(:category_data_school_cache_map).and_return(category_data_school_cache_map)
        allow(subject).to receive(:data).and_return(cache_data)
        allow(I18n).to receive(:db_t).with(label, default: label).and_return(translated_label)

        subject.transform_data_keys.each do |key, _|
          expect(key).to eq([label, translated_label, subject_id])
        end
      end
    end

    include_example 'it should make the keys [label, translated_label, subject_id] for subject_id', nil
    include_example 'it should make the keys [label, translated_label, subject_id] for subject_id', 47

  end

  describe '#select_breakdown_with_label' do
    let(:all_students) { 'aLl sTUdeNTs' }
    let(:breakdown) { 'breakdown' }
    let(:values) do
      [
        { breakdown: breakdown },
        { breakdown: all_students },
        {},
      ]
    end
    let(:config) { { breakdown_mappings: { label: breakdown } } }

    before do
      allow(subject).to receive(:config).and_return(config)
    end

    it 'should use a label\'s configuration' do
      selected_values = subject.select_breakdown_with_label(values, :label)
      expect(selected_values).to eq([ { breakdown: breakdown } ])
    end

    it 'should default to all students' do
      selected_values = subject.select_breakdown_with_label(values, :unconfigured_label)
      expect(selected_values).to eq([ { breakdown: all_students } ])
    end
  end
end
