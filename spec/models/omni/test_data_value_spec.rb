require 'spec_helper'

describe Omni::TestDataValue do
  before(:each) { do_clean_dbs :omni, :ca }
  after(:each) { do_clean_dbs :omni, :ca }

  let(:school) { create(:school) }
  let(:data_type) { create(:data_type, :with_tags, tag: Omni::TestDataValue::TAGS.first) }
  let(:source) { create(:source) }
  let(:proficiency_band) { create(:proficiency_band) }

  let(:data_set_none) { create(:data_set, :none, data_type: data_type, source: source) }
  let(:data_set_web) { create(:data_set, :web, data_type: data_type, source: source) }
  let(:data_set_feeds) { create(:data_set, :feeds, data_type: data_type, source: source) }

  let!(:test_data_value_none) do
    create(:test_data_value,
           gs_id: school.id,
           data_set_id: data_set_none.id,
           proficiency_band: proficiency_band)
  end

  let!(:test_data_value_web) do
    create(:test_data_value,
           gs_id: school.id,
           data_set_id: data_set_web.id,
           proficiency_band: proficiency_band)
  end

  let!(:test_data_value_feeds) do
    create(:test_data_value,
           gs_id: school.id,
           data_set_id: data_set_feeds.id,
           proficiency_band: proficiency_band)
  end

  describe ".common_query" do
    it 'returns an object that has the required keys' do
      result = Omni::TestDataValue.common_query

      results_keys = result.first.attributes.keys.map(&:to_sym)
      expected_keys = Omni::TestDataValue.required_keys_db_mapping.keys + [:id]

      expect(results_keys).to match_array(expected_keys)
    end
  end

  describe ".common_all_query(state)" do
    it 'returns objects for all configurations' do
      result = Omni::TestDataValue.common_all_query(school.state)
      expect(result.map(&:configuration)).to match_array([
                                                             Omni::DataSet::FEEDS,
                                                             Omni::DataSet::NONE,
                                                             Omni::DataSet::WEB,
                                                         ])
    end
  end

  describe ".common_feeds_query(state)" do
    it 'returns objects for feeds' do
      result = Omni::TestDataValue.common_feeds_query(school.state)
      expect(result.map(&:configuration)).to match_array([Omni::DataSet::FEEDS])
    end
  end

  describe ".all_by_school(state, id)" do
    subject(:results) { Omni::TestDataValue.all_by_school(school.state, school.id) }

    it 'returns the name of the associated data type' do
      expect(results.first.name).to eq(data_type.name)
    end

    it 'returns the id of the associated data type' do
      expect(results.first.data_type_id).to eq(data_type.id)
    end

    it 'returns the state of the associated data set' do
      expect(results.first.state).to eq(data_type.data_sets.first.state)
    end

    it 'returns the configuration of the associated data set' do
      expect(results.first.configuration).to eq(data_type.data_sets.first.configuration)
    end

    it 'returns the date_valid of the associated data set' do
      expect(results.first.date_valid).to eq(data_type.data_sets.first.reload.date_valid)
    end

    it 'returns the description of the associated data set' do
      expect(results.first.description).to eq(data_type.data_sets.first.description)
    end

    it 'returns the source name of the associated source' do
      expect(results.first.source).to eq(data_type.data_sets.first.source.name)
      expect(results.first.source_name).to eq(data_type.data_sets.first.source.name)
    end

    it 'returns the tag of the associated breakdown_tags' do
      expect(results.first.breakdown_tags).to eq(test_data_value_none.breakdown.breakdown_tags.first.tag)
    end

    it 'returns the name of the associated breakdown' do
      expect(results.first.breakdown_names).to eq(test_data_value_none.breakdown.name)
    end

  end

end
