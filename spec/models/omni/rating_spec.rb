# frozen_string_literal: true

require 'spec_helper'

describe Omni::Rating do
  before { clean_dbs :omni, :ca }

  describe ".by_school(state, id)" do
    let(:data_set) { create(:data_set, state: school.state, data_type: data_type) }
    let(:data_type) { Omni::DataType.create(name: "test") }
    let(:school) { create(:school) }
    let!(:data_type_tag) { Omni::DataTypeTag.create(data_type_id: data_set.data_type_id, tag: 'rating') }

    it 'returns an object that has the required keys' do
      Omni::Rating.create(entity_type: Omni::Rating::SCHOOL_ENTITY,
                          gs_id: school.id,
                          data_set_id: data_set.id,
                          value: 1)


      result = Omni::Rating.by_school(school.state, school.id)
      result_keys = result.first.attributes.keys.map(&:to_sym)
      expected_keys = Omni::Rating.required_keys_db_mapping.keys + [:id]

      expect(result_keys).to match_array(expected_keys)
    end
  end

  it 'does something' do

  end

end
