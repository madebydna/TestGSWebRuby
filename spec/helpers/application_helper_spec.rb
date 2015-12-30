require 'spec_helper'

describe ApplicationHelper do

  describe '#db_t' do
    before do
      allow(helper).to receive(:t)
    end
    it 'should remove periods from key' do
      key = 'foo.bar'
      expect(helper).to receive(:t).with('foobar')
      helper.db_t(key)
    end

    it 'should pass on options hash' do
      key = 'foo.bar'
      expect(helper).to receive(:t).with('foobar', default: 'default')
      helper.db_t(key, default: 'default')
    end

    it 'should accept symbols as arguments' do
      key = :'foo.bar'
      expect(helper).to receive(:t).with(:foobar)
      helper.db_t(key)
    end

    context 'when given blank key' do
      [nil, ''].each do |blank_key|
        it 'should return default value when one provided' do
          expect(helper).to_not receive(:t)
          result = helper.db_t(blank_key, default: 'default')
          expect(result).to eq('default')
        end
        it 'should return key if no default provided' do
          expect(helper).to_not receive(:t)
          result = helper.db_t(blank_key)
          expect(result).to eq(blank_key)
        end
      end
    end
  end
end
