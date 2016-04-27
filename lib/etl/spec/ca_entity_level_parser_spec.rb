require_relative '../ca_entity_level_parser.rb'

describe CaEntityLevelParser do
  let(:subject) { CaEntityLevelParser.new(row).parse }

  context 'with a county' do
    let(:row) { { county_code: '01', district_code: '000', school_id: '0000' } }
    let(:output_row) { { county_code: '01', district_code: '000', school_id: '0000', entity_level: 'county' } }

    it 'should add entity level column with county' do
      expect(subject).to eq(output_row)
    end
  end

  context 'with a district' do
    let(:row) { { county_code: '01', district_code: '001', school_id: '0000' } }
    let(:output_row) { { county_code: '01', district_code: '001', school_id: '0000', entity_level: 'district' } }
    it 'should add entity level column with district' do
      expect(subject).to eq(output_row)
    end
  end

  context 'with a school' do
    let(:row) { { county_code: '00', district_code: '000', school_id: '0001' } }
    let(:output_row) { { county_code: '00', district_code: '000', school_id: '0001', entity_level: 'school' } }
    it 'should add entity level column with school' do
      expect(subject).to eq(output_row)
    end
  end

  context 'with a state' do
    let(:row) { { county_code: '00', district_code: '000', school_id: '0000' } }
    let(:output_row) { { county_code: '00', district_code: '000', school_id: '0000', entity_level: 'state' } }
    it 'should add entity level column with state' do
      expect(subject).to eq(output_row)
    end
  end
end
