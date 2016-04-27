require 'spec_helper'
describe TrimLeadingZeros do 

  describe '#new' do
    it 'should raise error if no field provided' do
      expect { TrimLeadingZeros.new(nil) }.to raise_error
    end
  end

  describe '#process' do
    let(:field) { :foo }
    subject { TrimLeadingZeros.new(field) }
    let(:row) { Hash.new }

    it 'should trim leading zeros from 001' do
      row[field] = '001'
      expect(subject.process(row)[field]).to eq('1')
    end

    it 'should trim leading zeros from 000100' do
      row[field] = '000100'
      expect(subject.process(row)[field]).to eq('100')
    end

    it 'should not remove non-leading zeros from 100' do
      row[field] = '100'
      expect(subject.process(row)[field]).to eq('100')
    end

    it 'should not remove non-leading zeros from 101' do
      row[field] = '101'
      expect(subject.process(row)[field]).to eq('101')
    end
  end
end
