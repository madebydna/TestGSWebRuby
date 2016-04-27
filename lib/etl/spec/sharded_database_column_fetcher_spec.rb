require_relative '../sharded_database_column_fetcher'

describe  ShardedDatabaseColumnFetcher do
  context 'with no where statement' do
  let(:query_response) do
    [ {state_id: 1}, {state_id: 2}, {state_id: 3}, {state_id: 4} ]
  end
    let(:client) { double(query: query_response) }
    let(:subject) do
      fetcher = ShardedDatabaseColumnFetcher.new('dev.greatschools.org','ca', 'school', 'state_id')
      fetcher.instance_variable_set(:@client, client)
      fetcher
    end
    describe '#column' do
      it 'should make correct query' do
        expect(client).to receive(:query).with("SELECT state_id from _ca.school ")
        subject.column
      end
      it 'should return a array of hashes with column header as key for each value' do
        expect(subject.column).to eq(query_response)
      end
    end
    describe '#values_array' do
      it 'should make correct query' do
        expect(client).to receive(:query).with("SELECT state_id from _ca.school ")
        subject.values_array
      end
      it 'should return a array of hashes with column header as key for each value' do
        expect(subject.values_array).to eq((1..4).to_a)
      end
    end
  end
  context 'with where statement' do
    let(:client) { double() }
    let(:subject) do
      fetcher = ShardedDatabaseColumnFetcher.new('dev.greatschools.org','ca', 'school', 'state_id', 'where state_id != \'\'')
      fetcher.instance_variable_set(:@client, client)
      fetcher.column
    end
    it 'should make correct query' do
      expect(client).to receive(:query).with("SELECT state_id from _ca.school where state_id != ''")
      subject
    end
  end
end
