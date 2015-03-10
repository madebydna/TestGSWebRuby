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
        location: '2013/test_scores/sample_file.txt',
        header_rows: 1,
        layout: {
          school_id: 5, # School IDs are found within column 5.
          school_name: 6,
          district_id: 4,
          district_name: 6, # School names and district names are found in column 6.
          value: [7, 8, 11, 20], # The values are in columns 1, 7, and 20.
          number_tested: [2, 3],
          breakdown: :white, # All values in sample_file.txt are tagged breakdown: white.
          subject: {
            math: [2, 7, 8],
            writing: [3, 11, 20]
          },
          grade: 9,
          proficiency_band: {
            null: [8, 20], # The values in columns 8 and 20 are tagged proficiency_band: null.
            level_1: [7, 11]
          },
        }
      }
    }
    let(:mapping) { DataFileMapping.new(file_config) }
    let(:bad_hash_file_config) {
      # This config misuses the hash column mapping
      {
        header_rows: 1,
        location: '2013/path/to/file.txt',
        layout: {
          proficiency_band: {
            null: [20],
            level_1: 'this aint valid'
          },
        }
      }
    }
    let(:bad_hash_mapping) { DataFileMapping.new(bad_hash_file_config) }
    let(:expected_column_mapping) {
      {
        2 => {:number_tested=>true, :subject=>:math},
        3 => {:number_tested=>true, :subject=>:writing},
        4 => {:district_id=>true},
        5 => {:school_id=>true},
        6 => {:school_name=>true, :district_name=>true},
        7 => {:value=>true, :subject=>:math, :proficiency_band=>:level_1},
        8 => {:value=>true, :subject=>:math, :proficiency_band=>:null},
        9 => {:grade=>true},
        11 => {:value=>true, :subject=>:writing, :proficiency_band=>:level_1},
        20 => {:value=>true, :subject=>:writing, :proficiency_band=>:null},
        :file => {:breakdown=>:white},
      }
    }

    it 'should create a hash of columns or :file to descriptors' do
      mapping.parse_layout!
      expect(mapping.columns).to eq(expected_column_mapping)
    end

    it 'should raise a descriptive error if a column hash mapping is done incorrectly.' do
      expect { bad_hash_mapping.parse_layout! }.to raise_error(/proficiency_band.*this aint valid/)
    end
  end
end

