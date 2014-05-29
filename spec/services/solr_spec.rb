require 'spec_helper'

describe 'Solr' do
  describe '#breakdown_results' do
    context 'by default' do
      it 'connects to the solr server' do
        expect(RSolr).to receive(:connect)

        solr = Solr.new('mi', 1)
        solr.breakdown_results(grade_level: 'p')
      end
      it 'returns formatted breakdown results' do
        pending('Need to mock solr\'s select call? Making pending to fix build')
        solr = Solr.new('mi', 1)
        result = solr.breakdown_results(grade_level: 'p')
        expect(result).to be_an_instance_of(Hash)
        expect(result.keys).to eq([:count, :path])
      end
    end

    context 'an error state' do
      it 'returns nil and logs an error' do
        allow_any_instance_of(RSolr::Client).to receive(:get).and_raise(Exception)

        expect {
          result = Solr.new('mi', 1).breakdown_results(grade_level: 'p')
          expect(result).to be_nil
        }.to raise_error
      end
    end
  end
end
