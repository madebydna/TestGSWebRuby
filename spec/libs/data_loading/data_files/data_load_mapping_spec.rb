require 'spec_helper'

describe DataLoadMapping do

  describe '#initialize' do
    let(:file_configs) {
      [
        {
          location: '2014/test_scores/sample_file.txt',
          header_rows: 1,
          layout: {
            school_id: 5, # School IDs are found within column 5.
            school_name: 6,
            district_id: 4,
            district_name: 6, # School names and district names are found in column 6.
            value: [7, 8], # The values are in columns 7 and 8
            number_tested: [2, 3],
            grade: 9
          }
        },
        {
          location: '2014/test_scores/sample_file.txt',
          header_rows: 1,
          layout: {
            school_id: 5, # School IDs are found within column 5.
            school_name: 6,
            district_id: 4,
            district_name: 6, # School names and district names are found in column 6.
            value: [7, 8], # The values are in columns 7 and 8
            number_tested: [2, 3],
            grade: 10
          }
        }
      ]
    }

    let(:required_attrs_config) { { name: '2014 DC Test Load for grade 9 and 10', source: 'From the DC education board',
                                    files: file_configs} }

    required_attr_assertions = Proc.new do |required_attr|
      it "should not be valid, since #{required_attr} is not present" do
        required_attrs_config.delete(required_attr)
        expect(DataLoadMapping.new(required_attrs_config)).to_not be_valid
      end

      it "should be valid, since #{required_attr} is present" do
        expect(DataLoadMapping.new(required_attrs_config)).to be_valid
      end
    end

    [:name, :source, :files].each do |required_attr|
      context "#{required_attr} is required" do
        instance_exec(required_attr, &required_attr_assertions)
      end
    end

    context 'validate files' do
      let(:nil_file_configs) { { name: '2014 DC Test Load for grade 9 and 10', source: 'From the DC education board',
                                      files: nil} }
      let(:invalid_file_configs) {
        [
          {
            location: '2014/test_scores/sample_file.txt',
            header_rows: 1,
            layout: {
              school_id: 5, # School IDs are found within column 5.
              school_name: 6,
              district_id: 4,
              district_name: 6, # School names and district names are found in column 6.
              value: [7, 8], # The values are in columns 7 and 8
              number_tested: [2, 3],
              grade: 9
            }
          },
          {
            location: '2014/test_scores/sample_file.txt',
            header_rows: 1
          }
        ]
      }

      let(:data_configs) { { name: '2014 DC Test Load for grade 9 and 10', source: 'From the DC education board',
                             files: invalid_file_configs} }
      it 'should raise an error, since DataFileMapping throws error' do
        expect { DataLoadMapping.new(data_configs) }.to raise_error
      end

      it 'should not validate, since files is not an array' do
        expect(DataLoadMapping.new(nil_file_configs)).to_not be_valid
      end

      it 'should instantiate DataFileMapping twice.' do
        expect(DataFileMapping).to receive(:new).twice
        DataLoadMapping.new(data_configs)
      end

    end
  end


end