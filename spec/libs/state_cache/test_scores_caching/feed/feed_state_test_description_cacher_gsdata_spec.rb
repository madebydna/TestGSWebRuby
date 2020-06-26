require 'spec_helper'


describe TestScoresCaching::Feed::FeedStateTestDescriptionCacherGsdata do
  after(:all) { do_clean_dbs :omni }

  before(:all) do
    @state_test_ca = create(:data_type, :with_tags, name: "CA State Test 1", short_name: "CAST1", tag: "state_test")
    @data_set_ca_1_newer = create(:data_set, :feeds, state: "CA", description: "Some description here", data_type_id: @state_test_ca.id, date_valid: Date.new(2018, 8, 31))
    @data_set_ca_1_older = create(:data_set, :feeds, state: "CA", data_type_id: @state_test_ca.id, date_valid: Date.new(2017, 7, 31))

    state_test_ca_2 = create(:data_type, :with_tags, name: "CA State Test 2", short_name: "CAST2", tag: "state_test")
    @data_set_ca_2 = create(:data_set, :feeds, state: "CA", description: "Some description here", data_type_id: state_test_ca_2.id)

    data_type_other = create(:data_type, :with_tags, name: "CA Other", short_name: "CAOT", tag: "indicator")
    @data_set_ca_other = create(:data_set, :feeds, state: "CA", data_type_id: data_type_other.id)

    state_test_mi = create(:data_type, :with_tags, name: "MI State Test 1", short_name: "MAST2", tag: "state_test")
    @data_set_mi = create(:data_set, :feeds, state: "MI", data_type_id: state_test_mi.id)
  end

  subject(:cacher) { TestScoresCaching::Feed::FeedStateTestDescriptionCacherGsdata.new('CA') }

  describe '#query_results' do

    it 'selects latest data sets for state tests in given state' do
      expect(cacher.query_results).to include(@data_set_ca_1_newer, @data_set_ca_2)
    end

    it 'does not select older instances of particular state test' do
      expect(cacher.query_results).not_to include(@data_set_ca_1_older)
    end

    it 'does not select state tests for other state' do
      expect(cacher.query_results).not_to include(@data_set_mi)
    end

    it 'does not select data sets for non-state tests' do
      expect(cacher.query_results).not_to include(@data_set_ca_other)
    end
  end

  describe '#build_hash_for_cache' do
    subject(:hash) { cacher.build_hash_for_cache.detect {|ds| ds['test-name'] == "CA State Test 1"} }

    it 'has a most-recent-year key with the year of the state test' do
      expect(hash['most-recent-year']).to eq(2018)
    end

    it 'has a description key with the description of the test' do
      expect(hash['description']).to eq('Some description here')
    end

    it 'has a test-id key with the id of the state test' do
      expect(hash['test-id']).to eq(@state_test_ca.id)
    end

    it 'has a test-name key with the name of the state test' do
      expect(hash['test-name']).to eq("CA State Test 1")
    end

    it 'has a test-abbrv key with the abbreviation of the state test' do
      expect(hash['test-abbrv']).to eq("CAST1")
    end

    context 'with no proficiency band data' do
      it 'has a blank scale key' do
        expect(hash['scale']).to eq("")
      end
    end

    context 'with proficiency band data' do
      after(:each) { do_clean_models(:omni, Omni::ProficiencyBand)}
      before(:each) do
        @pb1 = create(:proficiency_band, id: 2, name: 'below average', group_id: 1, composite_of_pro_null: 1, group_order: 1)
        @pb2 = create(:proficiency_band, id: 3, name: 'average', group_id: 1, composite_of_pro_null: 1, group_order: 2)
        @pb3 = create(:proficiency_band, id: 4, name: 'above average', group_id: 1, composite_of_pro_null: 1, group_order: 3)

        @pb4 = create(:proficiency_band, id: 5, name: 'meeting', group_id: 2, composite_of_pro_null: 1, group_order: 1)
        @pb5 = create(:proficiency_band, id: 6, name: 'exceeding', group_id: 2, composite_of_pro_null: 1, group_order: 2)

        create(:test_data_value, data_set_id: @data_set_ca_1_newer.id, proficiency_band_id: @pb2.id)
        create(:test_data_value, data_set_id: @data_set_ca_2.id, proficiency_band_id: @pb5.id)
      end

      it 'returns a comma-separated scale value for proficiency bands with 3 and more levels' do
        hash = cacher.build_hash_for_cache.detect {|ds| ds['test-name'] == "CA State Test 1" }
        expect(hash['scale']).to eq("% below average, average, above average")
      end

      it 'returns an or-separated scale value for proficiency bands with 2 levels' do
        hash = cacher.build_hash_for_cache.detect {|ds| ds['test-name'] == "CA State Test 2" }
        expect(hash['scale']).to eq("% meeting or exceeding")
      end
    end
  end

end