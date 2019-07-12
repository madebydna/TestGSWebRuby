require 'spec_helper'

describe 'StateCacheDataReader' do
  let(:state) {'ca'}

  def new_reader(state, *args)
    StateCacheDataReader.new(state, *args)
  end

  describe '#initialize' do
    it 'should raise error if state isn\'t provided' do
      expect{new_reader}.to raise_error(ArgumentError)
    end

    it 'should raise error if keywords arguments isn\'t provided' do
      expect{new_reader('state', ['foo', 'bar', 'baz'])}.to raise_error(ArgumentError)
    end
  end

  context 'when given a state' do
    describe '#state_cache_query' do
      before do
        allow(StateCacheQuery).to receive(:for_state).and_return(query)
      end
      let(:query) do
        double('query').tap do |q|
          allow(q).to receive(:include_cache_keys).and_return(q)
        end
      end
      let(:reader) {new_reader(state)}

      it 'should make a query using the state' do
        expect(StateCacheQuery).to receive(:for_state).with(state)
        reader.state_cache_query
      end

      context 'when given specific cache keys' do
        let(:keys) { %w[foo bar] }
        let(:reader) { new_reader(state, state_cache_keys: keys) }

        it 'tells the query to include the right cache keys' do
          expect(query).to receive(:include_cache_keys).with(keys)
          reader.state_cache_query
        end
      end
    end

    describe '#characteristics_data' do
      let(:reader) { new_reader(state) }
      subject { reader.characteristics_data(:foo, :bar) }
      context 'with missing sources' do
        before do
          allow(reader).to receive(:decorated_state).and_return(
            OpenStruct.new(
              state_characteristics: {
                foo: [
                  {
                    'source' => 'abc',
                    'label' => 'foo label'
                  },
                  {
                    'label' => 'foo label'
                  }
                ],
                bar: [
                  {
                    'label' => 'foo label'
                  },
                  {
                    'source' => 'abc',
                    'label' => 'foo label'
                  }
                ]
              }
            )
          )
        end
        it 'should reject the hashes that have missing source' do
          expect(subject.values.flatten.select { |h| !h.has_key?('source') }).to be_empty
          expect(subject.values.flatten.select { |h| h.has_key?('source') }.size).to eq(2)
        end
      end
    end
  end
end