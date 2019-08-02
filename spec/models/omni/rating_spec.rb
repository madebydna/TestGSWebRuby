# frozen_string_literal: true

require 'spec_helper'

describe Omni::Rating do
  before { clean_dbs :omni, :ca }

  let(:school) { create(:school) }
  let(:data_type) { create(:data_type_with_tags, tag: Omni::Rating::TAGS.sample) }
  let(:data_set) { create(:data_set, state: school.state, data_type: data_type) }
  let(:breakdown) { create(:breakdown_with_tags) }

  describe ".by_school(state, id)" do
    let!(:rating) do
      Omni::Rating.create(entity_type: Omni::Rating::SCHOOL_ENTITY,
                          gs_id: school.id,
                          data_set_id: data_set.id,
                          value: 1,
                          breakdown: breakdown)
    end

    subject(:results) { Omni::Rating.by_school(school.state, school.id) }

    it 'returns an object that has the required keys' do
      results_keys = results.first.attributes.keys.map(&:to_sym)
      expected_keys = Omni::Rating.required_keys_db_mapping.keys + [:id]

      expect(results_keys).to match_array(expected_keys)
    end

    it 'returns the name of the associated data type' do
      expect(results.first.name).to eq(data_type.name)
    end

    it 'returns the id of the associated data type' do
      expect(results.first.data_type_id).to eq(data_type.id)
    end

    it 'returns the state of the associated data set' do
      expect(results.first.state).to eq(data_set.state)
    end

    it 'returns the configuration of the associated data set' do
      expect(results.first.configuration).to eq(data_set.configuration)
    end

    it 'returns the date_valid of the associated data set' do
      expect(results.first.date_valid).to eq(data_set.reload.date_valid)
    end

    it 'returns the description of the associated data set' do
      expect(results.first.description).to eq(data_set.description)
    end

    it 'returns the source name of the associated source' do
      expect(results.first.source).to eq(data_set.source.name)
      expect(results.first.source_name).to eq(data_set.source.name)
    end

    it 'returns the tag of the associated breakdown_tags' do
      expect(results.first.breakdown_tags).to eq(breakdown.breakdown_tags.first.tag)
    end

    it 'returns the name of the associated breakdown' do
      expect(results.first.breakdown_names).to eq(breakdown.name)
    end

  end

end
