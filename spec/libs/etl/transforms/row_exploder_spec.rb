require 'spec_helper'

describe RowExploder do

  describe '.new' do
    it 'should raise an error if label_field is not present' do
      expect { RowExploder.new(nil, :foo, :bar) }.to raise_error(ArgumentError)
    end
    it 'should raise an error if value_field is not present' do
      expect { RowExploder.new(:foo, nil, :bar) }.to raise_error(ArgumentError)
    end
    it 'should return a new instance when valid params are given' do
      expect(RowExploder.new(:foo, :bar, :baz, :baz2)).to be_a(RowExploder)
    end
  end

  describe '#process' do
    subject { RowExploder.new(:type, :value, :public, :private) }
    let(:row) do
      {
        public: 123,
        private: 456
      }
    end
    let(:result) { subject.process(row) }

    context 'when exploding two columns' do
      it 'should return two rows' do
        expect(result.size).to eq(2)
      end
      it 'each row should have the new label field' do
        result.each { |row| expect(row).to have_key(:type) }
      end
      it 'each row should have the new value field' do
        result.each { |row| expect(row).to have_key(:value) }
      end
      it 'the first exploded row should have "public" in the type field' do
        expect(result[0][:type]).to eq(:public)
      end
      it 'the second exploded row should have "private" in the type field' do
        expect(result[1][:type]).to eq(:private)
      end
      it 'the first exploded row should have "123" in the value field' do
        expect(result[0][:type]).to eq(:public)
      end
      it 'the second exploded row should have "456" in the valuefield' do
        expect(result[1][:type]).to eq(:private)
      end
    end

    it 'should record an event' do
      event_log = double('event log')
      expect(event_log).to receive(:process)
      subject.event_log = event_log
      subject.process(row)
    end

  end


end
