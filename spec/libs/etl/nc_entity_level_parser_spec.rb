require 'spec_helper'

describe NcEntityLevelParser do

  context 'with a school code containing string "sea"' do
    let(:row) { {:school_id => '550sea'} }
    let(:output_row) { NcEntityLevelParser.new(row).parse }

    it 'should add entity level column with value "state"' do
      expect(output_row).to eq({school_id:"550sea", entity_level:"state", state_id: "550", district_id: "550"})
    end
  end

  context 'with a school code containing string "LEA"' do
    let(:row) { {:school_id => '660LEA'} }
    let(:output_row) { NcEntityLevelParser.new(row).parse }

    it 'should add entity level column with value "district"' do
      expect(output_row).to eq({school_id:"660LEA", entity_level:"district", state_id: "660", district_id: "660"})
    end
  end

  context 'with a school code not containing "LEA" or "sea"' do
    let(:row) { {:school_id => '8675309'} }
    let(:output_row) { NcEntityLevelParser.new(row).parse }

    it 'should add entity level column with value "school"' do
      expect(output_row).to eq({school_id:"8675309", entity_level:"school", state_id:"8675309", district_id: "867"})
    end

    it 'should set state_id equal to the school_id' do
      expect(output_row).to eq({school_id:"8675309", entity_level:"school", state_id:"8675309", district_id: "867"})
    end

    it 'should set district_id equal to the first three characters of school_id' do
      expect(output_row).to eq({school_id:"8675309", entity_level:"school", state_id:"8675309", district_id: "867"})
    end

  end




end
