require 'spec_helper'

describe DataFileMapping do

  def should_require(required_method)
    required_attrs_config.delete(required_method)
    expect { DataFileMapping.new(required_attrs_config) }.to raise_error(RequiredAttributeMissing, required_method.to_s)
  end

  describe '#initialize' do
    let(:required_attrs_config) { { location: 'location', layout: {} } }

    context 'header rows' do

      it 'should default to 0 header rows' do
        mapping = DataFileMapping.new(required_attrs_config)
        expect(mapping.header_rows).to eq(0)
      end

      it 'should know the number of header rows' do
        mapping = DataFileMapping.new(required_attrs_config.merge({header_rows: 3}))
        expect(mapping.header_rows).to eq(3)
      end
    end

    context 'location' do

      it { should_require(:location) }

      it 'should know the location' do
        mapping = DataFileMapping.new(required_attrs_config.merge({location: '2013/path/to/file.txt'}))
        expect(mapping.location).to eq('2013/path/to/file.txt')
      end
    end

    context 'layout' do

      it { should_require(:layout) }

    end
  end

  describe '#parse_layout!' do

    let(:file_config) {
      # This config has all of the possible layout types
      {
        header_rows: 1,
        location: '2013/path/to/file.txt',
        layout: {
          school_id: 5,
          school_name: 6,
          district_id: 4,
          district_name: 6, # needs to handle repeat column number
          value_float: [20],
          number_tested: [19, 4, 5],
          breakdown: :white,
          subject: 'math',
          grade: 9,
          proficiency_band: {
            null: [20],
            level_1: 7
          },
        }
      }
    }
    let(:mapping) { DataFileMapping.new(file_config) }
    let(:expected_column_mapping) {
      {
        4=>{district_id: true, number_tested: true},
        5=>{school_id: true, number_tested: true},
        6=>{school_name: true, district_name: true},
        7=>{proficiency_band: :level_1},
        9=>{grade: true},
        19=>{number_tested: true},
        20=>{value_float: true, proficiency_band: :null},
        file: {subject: :math, breakdown: :white},
      }
    }

    it 'should create a hash of columns or :file to descriptors' do
      mapping.parse_layout!
      expect(mapping.columns).to eq(expected_column_mapping)
    end
  end
end

