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

    describe '#metrics_data' do
      let(:reader) { new_reader(state) }
      subject { reader.decorated_metrics_datas(:foo, :bar) }
      context 'with missing sources' do
        before do
          allow(reader).to receive(:decorated_state).and_return(
            OpenStruct.new(
              metrics: {
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
        it 'should extend values with MetricsCaching::Value::CollectionMethod' do
          expect(subject[:foo]).to respond_to(:for_all_students)
          expect(subject[:bar]).to respond_to(:having_most_recent_date)
        end
      end
    end

    describe '#school_levels' do
      subject { new_reader(state, state_cache_keys: 'school_levels') }

      before do
        @state_cache = FactoryBot.create(:state_cache, :with_school_levels)
      end

      after { clean_dbs :gs_schooldb }

      it "should returned the parsed hash from the state cache" do
        expect(subject.school_levels).to eq(JSON.parse(@state_cache.value))
      end

    end

    describe '#state_attributes' do
      subject { new_reader(state, state_cache_keys: 'state_attributes') }

      before do
        @state_cache = FactoryBot.create(:state_cache, :with_state_attributes)
      end

      after { clean_dbs :gs_schooldb }

      it "should returned the parsed hash from the state cache" do
        expect(subject.state_attributes).to eq(JSON.parse(@state_cache.value))
      end

    end

    describe '#state_attribute' do
      subject { new_reader(state, state_cache_keys: 'state_attributes') }

      before do
        @state_cache = FactoryBot.create(:state_cache, :with_state_attributes)
      end

      after { clean_dbs :gs_schooldb }

      it "should returned the parsed hash from the state cache" do
        expect(subject.state_attribute('growth_type')).to eq("Academic Progress Rating")
      end

      it 'should raise an error when an unknown key is passed in' do
        expect(subject.state_attribute('foobarbaz')).to be_nil
      end

    end
  end
end
