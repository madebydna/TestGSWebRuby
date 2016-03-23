require 'spec_helper'

describe NcEntityLevelParser do
  #let(:subject) { NcEntityLevelParser.new(row).parse }

  context 'with a school code containing string "sea"' do
    let(:row) { {:school_id => '550sea'} }
    let(:output_row) { NcEntityLevelParser.new(row).parse }

    it 'should add entity level column with value "state"' do
      expect(output_row).to eq({school_id:"550sea", entity_level:"state"})
    end
  end

  context 'with a school code containing string "LEA"' do
    let(:row) { {:school_id => '660LEA'} }
    let(:output_row) { NcEntityLevelParser.new(row).parse }

    it 'should add entity level column with value "district"' do
      expect(output_row).to eq({school_id:"660LEA", entity_level:"district"})
    end
  end

  context 'with a school code not containing "LEA" or "sea"' do
    let(:row) { {:school_id => '8675309'} }
    let(:output_row) { NcEntityLevelParser.new(row).parse }

    it 'should add entity level column with value "school"' do
      expect(output_row).to eq({school_id:"8675309", entity_level:"school"})
    end
  end

end
