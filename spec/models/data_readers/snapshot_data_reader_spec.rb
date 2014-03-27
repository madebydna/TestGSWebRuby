require 'spec_helper'

describe SnapshotDataReader do
  let(:school) { FactoryGirl.build(:school) }
  subject(:reader) { SnapshotDataReader.new school }

  describe '#should_show_data_for_key?' do

    it 'should correctly match school_types' do
      key_filters = {
        blah: {
          school_types: ['charter', 'private'],
        }
      }
      reader.stub(:key_filters).and_return key_filters

      school.type = 'public'
      expect(reader.send :should_show_data_for_key?, :blah).to be_false

      school.type = 'charter'
      expect(reader.send :should_show_data_for_key?, :blah).to be_true

      school.type = 'private'
      expect(reader.send :should_show_data_for_key?, :blah).to be_true
    end

    it 'should correctly match level codes' do
      key_filters = {
        blah: {
          level_codes: ['p', 'h'],
        }
      }
      reader.stub(:key_filters).and_return key_filters

      school.level_code = 'p'
      expect(reader.send :should_show_data_for_key?, :blah).to be_true

      school.level_code = 'e'
      expect(reader.send :should_show_data_for_key?, :blah).to be_false

      school.level_code = 'm'
      expect(reader.send :should_show_data_for_key?, :blah).to be_false

      school.level_code = 'h'
      expect(reader.send :should_show_data_for_key?, :blah).to be_true
    end

    it 'should correctly handle blank school level code' do
      key_filters = {
        blah: {
          level_codes: ['p', 'h'],
        }
      }
      reader.stub(:key_filters).and_return key_filters

      school.level_code = nil
      expect(reader.send :should_show_data_for_key?, :blah).to be_false

      school.level_code = ''
      expect(reader.send :should_show_data_for_key?, :blah).to be_false
    end



  end


end
