require 'spec_helper'

describe SnapshotDataReader do
  let(:school) { FactoryGirl.build(:school) }
  subject(:reader) { SnapshotDataReader.new school }

  describe '#should_show_data_for_key?' do

    it 'should correctly match school_types' do
      key_filters = {
        blah: {
          school_types: ['charter', 'private'],
        }
      }
      reader.stub(:key_filters).and_return key_filters

      school.type = 'public'
      expect(reader.send :should_show_data_for_key?, :blah).to be_falsey

      school.type = 'charter'
      expect(reader.send :should_show_data_for_key?, :blah).to be_truthy

      school.type = 'private'
      expect(reader.send :should_show_data_for_key?, :blah).to be_truthy
    end

    it 'should correctly match level codes' do
      key_filters = {
        blah: {
          level_codes: ['p', 'h'],
        }
      }
      reader.stub(:key_filters).and_return key_filters

      school.level_code = 'p'
      expect(reader.send :should_show_data_for_key?, :blah).to be_truthy

      school.level_code = 'e'
      expect(reader.send :should_show_data_for_key?, :blah).to be_falsey

      school.level_code = 'm'
      expect(reader.send :should_show_data_for_key?, :blah).to be_falsey

      school.level_code = 'h'
      expect(reader.send :should_show_data_for_key?, :blah).to be_truthy
    end

    it 'should correctly handle blank school level code' do
      key_filters = {
        blah: {
          level_codes: ['p', 'h'],
        }
      }
      reader.stub(:key_filters).and_return key_filters

      school.level_code = nil
      expect(reader.send :should_show_data_for_key?, :blah).to be_falsey

      school.level_code = ''
      expect(reader.send :should_show_data_for_key?, :blah).to be_falsey
    end
  end

  describe '#data_for_all_sources_for_category' do
    it 'should call all the school data reader methods for each configured source' do
      key_filters = {
        :'head official name' => {
          source: 'census_data_points'
        },
        transportation: {
          source: 'esp_data_points'
        }
      }
      reader.stub(:key_filters).and_return key_filters

      category = double('category').as_null_object

      expect(school).to receive(:census_data_points).with(category).and_return({})
      expect(school).to receive(:esp_data_points).with(category).and_return({ a: 1 })

      expected = {
        census_data_points: {},
        esp_data_points: { a: 1 }
      }
      expect(reader.send :data_for_all_sources_for_category, category).to eq(expected)
    end
  end

  describe '#data_for_category' do
    let(:category) { double('category') }

    before do
      @key_filters = {
        enrollment: {
          source: 'census_data_points'
        },
        hours: {
          source: 'esp_data_points'
        }
      }
      @example_data = {
        census_data_points: {},
        esp_data_points: { 'hours' => 2 }
      }

      @category_data = [
        FactoryGirl.build(:category_data, response_key: 'enrollment', label: 'enrollment'),
        FactoryGirl.build(:category_data, response_key: 'hours', label: 'hours')
      ]

      category.stub(:category_data).and_return @category_data
      reader.stub(:key_filters).and_return @key_filters
      subject.stub(:data_for_all_sources_for_category).and_return @example_data
    end

    it 'should default values to "no info"' do
      @example_data = {
        census_data_points: {},
        esp_data_points: { 'hours' => 2 }
      }
      subject.stub(:data_for_all_sources_for_category).and_return @example_data

      expect(subject.data_for_category category).to include({'enrollment' => { label: 'enrollment', school_value: 'no info' }})
      expect(subject.data_for_category category).to include({'hours' => { label: 'hours', school_value: 2 }})
    end

    it 'should use label specified in category_data' do
      @category_data = [
        FactoryGirl.build(:category_data, response_key: 'enrollment', label: 'enrollment blah'),
      ]
      category.stub(:category_data).and_return @category_data

      expect(subject.data_for_category category).to include({'enrollment' => { label: 'enrollment blah', school_value: 'no info' }})
    end

    it 'should default label to the key, if label is not specified' do
      @category_data = [
        FactoryGirl.build(:category_data, response_key: 'enrollment', label: nil),
      ]
      category.stub(:category_data).and_return @category_data

      expect(subject.data_for_category category).to include({'enrollment' => { label: 'enrollment', school_value: 'no info' }})
    end
  end

  describe '#key_filters' do
    it 'should return a hash' do
      expect(subject.key_filters).to be_a Hash
    end
  end


end
