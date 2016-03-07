require 'spec_helper'

describe HashLookup do
  describe '.initialize' do
    context 'with empty key' do
      subject { HashLookup.new(nil, {}) }
      it 'is expected to raise error' do
        expect { subject }.to raise_error
      end
    end
    context 'with empty destination key' do
      subject { HashLookup.new(:foo, {}, nil) }
      it 'is expected to raise error' do
        expect { subject }.to raise_error
      end
    end
    context 'when nil hash' do
      subject { HashLookup.new(:foo, nil, :bar) }
      it 'is expected to raise error' do
        expect { subject }.to raise_error
      end
    end

    context 'with valid attributes' do
      subject { HashLookup.new(:foo, {}, :bar) }
      it 'is expected to raise error' do
        expect { subject }.to_not raise_error
      end
    end
  end

  describe '#process' do
    let(:lookup_hash) do
      {
        a: :Apple,
        b: :Blackberry
      }
    end
    subject { transformer.process(row) }
    context 'when not providing destination key' do
      let(:transformer) { HashLookup.new(:foo, lookup_hash) }
      context 'when row has the key to look up' do
        let(:row) do
          {
            foo: :b
          }
        end
        it 'should lookup and assign the value in lookup hash' do
          expect(subject[:foo]).to eq(:Blackberry)
        end
      end

      context 'when value doesnt exist in lookup table' do
        let(:row) do
          {
            foo: :alfdj
          }
        end
        it 'should overwrite with nil' do
          expect(subject[:foo]).to be_nil
        end
      end
    end

    context 'when providing destination key' do
      let(:transformer) { HashLookup.new(:foo, lookup_hash, :bar) }
      context 'when row has the key to look up' do
        let(:row) do
          {
            foo: :b
          }
        end
        it 'should lookup and assign the value in lookup hash' do
          expect(subject[:foo]).to eq(:b)
          expect(subject[:bar]).to eq(:Blackberry)
        end
      end

      context 'when value doesnt exist in lookup table' do
        let(:row) do
          {
            foo: :alfdj
          }
        end
        it 'should overwrite with nil' do
          expect(subject[:foo]).to eq(:alfdj)
          expect(subject[:bar]).to be_nil
        end
      end
    end


  end
end
