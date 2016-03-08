require 'spec_helper'

describe GsShardedDatabaseSource do
  let(:query_response) do
    [ FactoryGirl.attributes_for(:demo_school, state_id: 1),
      FactoryGirl.attributes_for(:demo_school, state_id: 2) ]
  end
  let(:client) { double(query: query_response) }
  context 'with no where statement' do
    let(:args) { {host: 'datadev', state: 'ca', table: 'school' } }
    let(:subject) do
      fetcher = GsShardedDatabaseSource.new(args)
      fetcher.instance_variable_set(:@client, client)
      fetcher
    end
    describe '#each' do
      it 'returns the right data' do
        results = []
        subject.each { |data| results << data }
        expect(results).to eq(query_response)
      end
    end
  end
  context 'with where statement' do
    let(:args) { {host: 'datadev', state: 'ca', table: 'school', where: 'where state_id != \'\'' } }
    let(:subject) do
      fetcher =  GsShardedDatabaseSource.new(args)
      fetcher.instance_variable_set(:@client, client)
      fetcher.each
    end
    it 'should make correct query' do
      expect(client).to receive(:query).with("SELECT * from _ca.school where state_id != ''")
      subject { |data| data }
    end
  end
end

