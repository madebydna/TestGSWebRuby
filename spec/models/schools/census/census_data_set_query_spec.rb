require 'spec_helper'

describe CensusDataSetQuery do
  subject { CensusDataSetQuery.new('ca') }
  let(:relation) { double('relation').as_null_object }
  before(:each) do
    subject.instance_variable_set(:@relation, relation)
  end

  describe '#default_scope' do
    it 'should enforce only active data sets' do
      # TODO: what's the correct way to
      CensusDataSet = class_double('CensusDataSet').as_stubbed_const
      allow(CensusDataSet).to receive(:on_db).and_return(CensusDataSet)
      allow(CensusDataSet).to receive(:active).and_return(CensusDataSet)
      allow(CensusDataSet).to receive(:scoped).and_return(CensusDataSet)
      # CensusDataSet = double(CensusDataSet).as_null_object
      expect(CensusDataSet).to receive(:active)
      subject.default_scope
      # CensusDataSet = CensusDataSetCopy
    end
  end

  describe '#with_data_types' do
    it 'should add with_data_types scope' do
      expect(relation).to receive(:with_data_types).with([1, 2, 3])
      subject.with_data_types([1, 2, 3])
    end

    it 'should return self' do
      expect(subject.with_data_types(1)).to be_a CensusDataSetQuery
    end
  end

  describe '#with_subjects' do
    it 'should add subject criteria' do
      expect(relation).to receive(:where).with(subject_id: [1, 2])
      subject.with_subjects([1, 2])
    end

    it 'should return self' do
      expect(subject.with_subjects(1)).to be_a CensusDataSetQuery
    end
  end

  describe '#with_school_values' do
    it 'should ask rails to eager load school values' do
      expect(relation).to receive(:eager_load)
        .with(:census_data_school_values)
        .and_return relation
      subject.with_school_values(1)
    end

    it 'should use a custom string join to make sure that SQL \
ON clause contains school_id constraint' do
      allow(relation).to receive(:eager_load).and_return relation
      expect(relation).to receive(:joins).with(
        'AND census_data_school_value.school_id = 1'
      )
      subject.with_school_values(1)
    end
  end

  describe '#with_district_values' do
    it 'should set a district ID' do
      expect { subject.with_district_values(1) }
        .to change{ subject.instance_variable_get(:@district_id) }
        .from(nil)
        .to(1)
    end

    it 'should tell the query to include district values' do
      expect { subject.with_district_values(1) }
        .to change{ subject.instance_variable_get(:@include_district_values) }
        .from(false)
        .to(true)
    end

    it 'should return itself' do
      expect(subject.with_district_values(1)).to be_a CensusDataSetQuery
    end
  end

  describe '#with_census_descriptions' do
    it 'should set a school type' do
      expect { subject.with_census_descriptions('public') }
        .to change{ subject.instance_variable_get(:@school_type) }
        .from(nil)
        .to('public')
    end

    it 'should tell the query to include census descriptions' do
      expect { subject.with_census_descriptions('public') }
        .to change{
          subject.instance_variable_get(:@include_census_descriptions)
        }
        .from(false)
        .to(true)
    end

    it 'should return itself' do
      expect(subject.with_census_descriptions('a')).to be_a CensusDataSetQuery
    end
  end

  describe '#with_state_values' do
    it 'should tell the query to include state values' do
      expect { subject.with_state_values }
        .to change { subject.instance_variable_get(:@include_state_values) }
        .from(false)
        .to(true)
    end

    it 'should return itself' do
      expect(subject.with_state_values).to be_a CensusDataSetQuery
    end
  end

  describe '#load_district_values' do
    let(:data_set_without_district_values) do
      FactoryGirl.build(:census_data_set)
    end
    it 'should load a district value onto a data set' do
      allow(subject).to receive(:district_values).and_return FactoryGirl.build_list(
        :census_data_district_value, 1,
        data_set_id: data_set_without_district_values.id
      )
      allow(subject).to receive(:data_sets).and_return [ data_set_without_district_values ]

      subject.load_district_values

      expect(data_set_without_district_values.district_value).to_not be_blank
    end

    it 'should be idempotent' do
      allow(subject).to receive(:data_sets).and_return []
      expect(subject.load_district_values).to_not be_nil
      expect(subject.load_district_values).to be_nil
    end
  end

  describe '#district_values' do
    it 'should return empty array if district_id not set' do
      subject.instance_variable_set(:@district_id, nil)
      expect(subject.district_values).to be_empty
    end

    it 'should empty array if district ID is zero' do
      subject.instance_variable_set(:@district_id, 0)
      expect(subject.district_values).to be_empty
    end

    it 'should query for district values' do
      subject.instance_variable_set(:@district_id, 4)
      allow(subject).to receive(:data_set_ids).and_return [1, 2]
      allow(CensusDataDistrictValue).to receive_message_chain(:on_db, :where)
      expect(CensusDataDistrictValue).to receive(:on_db).with(:ca)
      subject.district_values
    end

    it 'should specify the district ID and data set ID' do
      subject.instance_variable_set(:@district_id, 4)
      allow(subject).to receive(:data_set_ids).and_return [1, 2]
      allow(CensusDataDistrictValue).to receive(:on_db).and_return CensusDataDistrictValue
      allow(CensusDataDistrictValue).to receive(:where).and_return CensusDataDistrictValue
      expect(CensusDataDistrictValue).to receive(:where)
        .with(
          district_id: 4,
          data_set_id: [1, 2]
        )
      subject.district_values
    end
  end

  describe '#load_state_values' do
    let(:data_set_without_state_values) {
      FactoryGirl.build(:census_data_set,
        census_data_state_values: []
      )
    }
    it 'should load a state value onto a data set' do
      allow(subject).to receive(:state_values).and_return FactoryGirl.build_list(
        :census_data_state_value, 1,
        data_set_id: data_set_without_state_values.id
      )
      allow(subject).to receive(:data_sets).and_return [ data_set_without_state_values ]

      subject.load_state_values

      expect(data_set_without_state_values.state_value).to_not be_blank
    end

    it 'should be idempotent' do
      allow(subject).to receive(:data_sets).and_return []
      expect(subject.load_state_values).to_not be_nil
      expect(subject.load_state_values).to be_nil
    end
  end

  describe '#state_values' do
    it 'should query for state values' do
      allow(subject).to receive(:data_set_ids).and_return [1, 2]
      allow(CensusDataStateValue).to receive_message_chain(:on_db, :where)
      expect(CensusDataStateValue).to receive(:on_db).with(:ca)
      subject.state_values
    end
  end

  describe '#census_descriptions' do
    it 'should query for census descriptions' do
      allow(subject).to receive(:data_set_ids).and_return [1, 2]
      subject.instance_variable_set(:@school_type, 'private')
      allow(CensusDescription).to receive_message_chain(:where)
      expect(CensusDescription).to receive(:where)
        .with(state: 'ca', school_type: 'private', census_data_set_id: [1, 2])
      subject.census_descriptions
    end
  end

  describe '#load_census_descriptions' do
    let(:data_set_without_census_description) {
      FactoryGirl.build(:census_data_set)
    }
    it 'should load a description onto a data set' do
      allow(subject).to receive(:census_descriptions).and_return FactoryGirl.build_list(
        :census_description,
        1,
        census_data_set_id: data_set_without_census_description.id
      )
      allow(subject).to receive(:data_sets) {
        [ data_set_without_census_description ]
      }

      subject.load_census_descriptions

      expect(data_set_without_census_description.source).to_not be_blank
    end

    it 'should be idempotent' do
      allow(subject).to receive(:data_sets).and_return []
      expect(subject.load_census_descriptions).to_not be_nil
      expect(subject.load_census_descriptions).to be_nil
    end
  end

  describe '#config_entry_for_data_set' do
    it 'should ask for config entry related to given data set' do
      allow(CensusDataConfigEntry).to receive(:for_data_set).and_return nil
      expect(CensusDataConfigEntry).to receive(:for_data_set)
        .with(:ca, 10)
      subject.config_entry_for_data_set 10
    end
  end

  describe '#load_config_entries' do
    let(:data_set_without_config_entry) do
      FactoryGirl.build(:census_data_set)
    end
    it 'should load a config entry onto a data set' do
      allow(subject).to receive(:config_entry_for_data_set)
        .and_return FactoryGirl.build(:census_data_config_entry)
      allow(subject).to receive(:data_sets) do
        [data_set_without_config_entry]
      end

      subject.load_config_entries

      expect(data_set_without_config_entry).to have_config_entry
    end

    it 'should be idempotent' do
      allow(subject).to receive(:data_sets).and_return []
      expect(subject.load_config_entries).to_not be_nil
      expect(subject.load_config_entries).to be_nil
    end
  end

end
