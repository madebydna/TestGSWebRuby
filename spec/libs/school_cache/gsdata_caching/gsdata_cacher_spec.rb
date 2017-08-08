require 'spec_helper'

describe GsdataCaching::GsdataCacher do
  before do
    clean_dbs(:_ca, :gs_schooldb)
  end
  describe '#build_hash_for_cache' do
    it 'should return correct hash' do
      tags = ['a', 'b']
      school = build(:alameda_high_school)
      gsdb_cacher = GsdataCaching::GsdataCacher.new(school)
      breakdowns = ['AA', 'BB', 1]
      date_valid = Time.zone.parse('Jan 1 2014').to_s
      data_type_one_values = build_school_values(1,
                                                 'Data Type 1',
                                                 date_valid,
                                                 tags,
                                                 *breakdowns)
      data_type_two_values = build_school_values(2,
                                                 'Data Type 2',
                                                 date_valid,
                                                 tags,
                                                 *breakdowns)
      all_values = data_type_one_values + data_type_two_values
      state_results = build_state_results_hash(breakdowns,
                                               date_valid,
                                               *[1, 2])
      district_results = build_state_results_hash(breakdowns,
                                                  date_valid,
                                                  *[1, 2])
      allow(gsdb_cacher).to receive(:school_results).and_return(all_values)
      allow(gsdb_cacher).to receive(:state_results_hash)
        .and_return(state_results)
      allow(gsdb_cacher).to receive(:district_results_hash)
        .and_return(district_results)
      breakdown_one_result_hashes = breakdowns.map do |bd|
        build_result_hash(bd, tags)
      end
      breakdown_two_result_hashes = breakdowns.map do |bd|
        build_result_hash(bd, tags)
      end
      result = {
        'Data Type 1' => breakdown_one_result_hashes,
        'Data Type 2' => breakdown_two_result_hashes
      }
      expect(gsdb_cacher.build_hash_for_cache).to be_a(Hash)
      expect(gsdb_cacher.build_hash_for_cache).to eq(result)
    end
  end

  def build_state_results_hash(breakdowns, source_year, *data_type_ids)
    breakdowns.each_with_object({}) do |bd, h|
      data_type_ids.each do |data_type_id|
        h[[data_type_id, bd, source_year]] = 1
      end
    end
  end

  def build_result_hash(breakdown, breakdown_tags)
    {
      breakdowns: breakdown,
      breakdown_tags: breakdown_tags,
      school_value: 1,
      state_value: 1,
      district_value: 1,
      source_name: 'Sample Source',
      source_year: 2014
    }
  end

  def build_school_values(data_type_id, name, date_valid, breakdown_tags, *breakdowns)
    breakdowns.map do |bd|
      data_value = build(:school_data_value,
                         breakdowns: bd,
                         breakdown_tags: breakdown_tags,
                         data_type_id: data_type_id,
                         name: name)
      allow(data_value).to receive(:datatype_breakdown_year)
        .and_return([data_type_id, bd, date_valid])
      data_value
    end
  end

  describe 'school_results' do
    it 'should return data values for school and data_types ids' do
      school = build(:alameda_high_school)
      gsdb_cacher = GsdataCaching::GsdataCacher.new(school)
      stub_const('GsdataCaching::GsdataCacher::DATA_TYPE_IDS', [5, 6])
      stub_const('GsdataCaching::GsdataCacher::BREAKDOWN_TAG_NAMES', [:a, :b])
      data_values = double
      stub_const('DataValue', data_values)

      expect(data_values)
        .to receive(:find_by_school_and_data_types)
        .with(
          school,
          GsdataCaching::GsdataCacher::DATA_TYPE_IDS,
          GsdataCaching::GsdataCacher::BREAKDOWN_TAG_NAMES
        )
      gsdb_cacher.school_results
    end
  end

  describe 'state_results_hash' do
    it 'should return map of values for each state breakdown' do
      school = build(:alameda_high_school)
      data_type_id = 95
      gsdb_cacher = GsdataCaching::GsdataCacher.new(school)
      stub_const('GsdataCaching::GsdataCacher::DATA_TYPE_IDS', [5, 6])
      stub_const('GsdataCaching::GsdataCacher::BREAKDOWN_TAG_NAMES', [:a, :b])
      data_values = double
      stub_const('DataValue', data_values)
      state_value = double(
        data_type_id: data_type_id,
        breakdowns: 'blah',
        value: 'value',
        datatype_breakdown_year: ['key', 1, 'key2']
      )
      state_values = [state_value]

      allow(data_values).to receive(:find_by_state_and_data_types)
        .with(
          school.state,
          GsdataCaching::GsdataCacher::DATA_TYPE_IDS,
          GsdataCaching::GsdataCacher::BREAKDOWN_TAG_NAMES
        )
        .and_return(state_values)
      results = {
        state_value.datatype_breakdown_year => state_value.value
      }

      expect(gsdb_cacher.state_results_hash).to be_a(Hash)
      expect(gsdb_cacher.state_results_hash).to eq(results)
    end
  end

  describe 'district_results_hash' do
    it 'should return map of values for each state breakdown' do
      school = build(:alameda_high_school)
      data_type_id = 95
      gsdb_cacher = GsdataCaching::GsdataCacher.new(school)
      stub_const('GsdataCaching::GsdataCacher::DATA_TYPE_IDS', [5, 6])
      stub_const('GsdataCaching::GsdataCacher::BREAKDOWN_TAG_NAMES', [:a, :b])
      data_values = double
      stub_const('DataValue', data_values)
      district_value = double(
        data_type_id: data_type_id,
        breakdowns: 'blah',
        value: 'value',
        datatype_breakdown_year: ['key', 1, 'key2']
      )
      district_values = [district_value]

      allow(DataValue).to receive(:establish_connection)
      allow(DataValue).to receive(:find_by_district_and_data_types)
        .with(
          school.state,
          school.district_id,
          GsdataCaching::GsdataCacher::DATA_TYPE_IDS,
          GsdataCaching::GsdataCacher::BREAKDOWN_TAG_NAMES
        )
        .and_return(district_values)
      results = {
        district_value.datatype_breakdown_year => district_value.value
      }

      expect(gsdb_cacher.district_results_hash).to be_a(Hash)
      expect(gsdb_cacher.district_results_hash).to eq(results)
    end
  end
end
