require_relative '../../transforms/hash_lookup'

RSpec.shared_examples 'record ignored values' do
  it 'should record value as ignored' do
    ignored_key = "foo:alfdj"
    expect(transformer).to receive(:record).with(be_kind_of(Hash), :executed, ignored_key)
    expect(transformer).to receive(:record).with(be_kind_of(Hash), :"alfdj ignored", ignored_key)
    subject[:foo]
  end
end

RSpec.shared_examples 'record unmapped values' do
  it 'should record value as not mapped' do
    not_mapped_key = "foo:alfdj"
    expect(transformer).to receive(:record).with(be_kind_of(Hash), :executed, not_mapped_key)
    expect(transformer).to receive(:record).with(be_kind_of(Hash), :"* Not Mapped *", not_mapped_key)
    subject[:foo]
  end
end

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
      subject { HashLookup.new(:foo, nil, to: :bar) }
      it 'is expected to raise error' do
        expect { subject }.to raise_error
      end
    end

    context 'with valid attributes' do
      subject { HashLookup.new(:foo, {}, to: :bar) }
      it 'is expected to not raise error' do
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
      let(:options) { {} }
      let(:transformer) { HashLookup.new(:foo, lookup_hash, options) }
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
        context 'when value ignored' do
          let(:options) { { ignore: [:alfdj]} }
          it 'should not overwrite value' do
            expect(subject[:foo]).to eq(:alfdj)
          end
          include_examples 'record ignored values'
        end
        context 'when value is not ignored' do
          it 'should not overwrite value' do
            expect(subject[:foo]).to eq(:alfdj)
          end
          include_examples 'record unmapped values'
        end
      end
      end

    context 'when providing destination key' do
      let(:options) { { to: :bar} }
      let(:transformer) { HashLookup.new(:foo, lookup_hash, options) }
      subject { transformer.process(row) }

      context 'when destination key is a brand new column' do
        context 'when value is found in lookup table' do
          let(:row) do
            {
              foo: :b
            }
          end
        end

        context 'when value is not in lookup table' do
          let(:row) do
            {
              foo: :alfdj
            }
          end
          context 'with the value not ignored' do
            it 'should create new column with value nil' do
              expect(subject[:foo]).to eq(:alfdj)
              expect(subject.has_key?(:bar)).to eq(true)
              expect(subject[:bar]).to be_nil
            end
            include_examples 'record unmapped values'
          end
          context 'with value ignored' do
            let(:options) { { to: :bar, ignore: [:alfdj]} }
            it 'should create new column with nil' do
              expect(subject[:foo]).to eq(:alfdj)
              expect(subject.has_key?(:bar)).to eq(true)
              expect(subject[:bar]).to be_nil
            end
            include_examples 'record ignored values'
          end
        end
      end
      context 'when destination key is an existing column' do
        context 'when destination key has a current value' do
          context 'when value is not found in lookup table' do
            let(:row) do
              {
                foo: :value_not_in_lookup_hash,
                bar: :buddy
              }
            end
            it 'destination key should keep current value' do
              expect(subject[:bar]).to eq(:buddy)
            end
          end
          context 'when value is found in lookup table' do
            let(:row) do
              {
                foo: :b,
                bar: :buddy
              }
            end
            it 'should lookup and assign the value in lookup hash to destination key' do
              expect(subject[:bar]).to eq(:Blackberry)
            end
          end
        end
      end
    end
  end
end
